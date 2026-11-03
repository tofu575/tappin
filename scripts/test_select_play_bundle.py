import json
import os
from pathlib import Path
import tempfile
import unittest
from unittest.mock import MagicMock, patch

from bundle_artifact import BundleArtifact
from play_max_version import play_max_version
from select_play_bundle import select_play_bundle
from upload_play import PlayError


class SelectBundleTest(unittest.TestCase):
    """Check version allocation, reuse decisions, and Play edit cleanup."""

    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        previous = Path.cwd()
        os.chdir(self.temp.name)
        self.addCleanup(os.chdir, previous)
        self.sha = "a" * 40
        Path("pubspec.yaml").write_text("version: 0.1.0+1\n")
        Path(".flutter-version").write_text("3.44.9\n")
        self.env = dict(TARGET_SHA=self.sha, BASE_VERSION_CODE="0", GITHUB_RUN_NUMBER="2",
                        GITHUB_RUN_ATTEMPT="1", GITHUB_REPOSITORY="tofu575/glarea",
                        RUNNER_TEMP=self.temp.name, GITHUB_OUTPUT=f"{self.temp.name}/output",
                        PLAY_PACKAGE_NAME="com.tofu575.glarea", PLAY_MAX_VERSION_CODE="1000",
                        PLAY_SERVICE_ACCOUNT_JSON=json.dumps({"type": "service_account"}))
        for target in ("bundle_artifact.subprocess.check_output",
                       "google.oauth2.service_account.Credentials.from_service_account_info",
                       "google.auth.transport.requests.AuthorizedSession", "select_play_bundle.play_max_version"):
            mocked = patch(target)
            result = mocked.start()
            self.addCleanup(mocked.stop)
            if target.endswith("check_output"):
                result.return_value = self.sha + "\n"
            if target == "select_play_bundle.play_max_version":
                result.return_value = 1500

    def output(self):
        """Read the concrete workflow outputs consumed by build, sign, and upload."""
        return dict(line.split("=", 1) for line in Path(self.env["GITHUB_OUTPUT"]).read_text().splitlines())

    def test_obsolete_automatic_deployment_is_skipped_before_play_or_artifact_access(self):
        with patch.object(BundleArtifact, "api", return_value={"object": {"sha": "b" * 40}}), \
                patch.object(BundleArtifact, "find") as find, \
                patch("google.oauth2.service_account.Credentials.from_service_account_info") as credentials:
            select_play_bundle(dict(self.env, AUTO_DEPLOY="true"))
        self.assertEqual(self.output(), {"deploy": "false"})
        find.assert_not_called()
        credentials.assert_not_called()

    def test_current_main_commit_can_use_its_ci_bundle(self):
        with patch.object(BundleArtifact, "api", return_value={"object": {"sha": self.sha}}), \
                patch.object(BundleArtifact, "find", return_value=2001):
            select_play_bundle(dict(self.env, AUTO_DEPLOY="true"))
        self.assertEqual(self.output()["deploy"], "true")
        self.assertEqual(self.output()["found"], "true")

    def test_cache_hit_preserves_ci_version_without_allocating_a_cd_version(self):
        with patch.object(BundleArtifact, "find", return_value=2001), \
                patch.object(BundleArtifact, "fresh_version", side_effect=AssertionError("must not allocate")):
            select_play_bundle(self.env)
        self.assertEqual(self.output()["found"], "true")
        self.assertEqual(self.output()["version_code"], "2001")
        self.assertTrue(self.output()["bundle"].endswith("android-bundle/app-release.aab"))

    def test_cache_miss_rebuilds_above_visible_play_versions(self):
        with patch.object(BundleArtifact, "find", return_value=None):
            select_play_bundle(self.env)
        self.assertEqual(self.output()["found"], "false")
        self.assertEqual(self.output()["version_code"], "1501")
        self.assertEqual(self.output()["bundle"], "build/app/outputs/bundle/release/app-release.aab")

    def test_cd_counter_cannot_jump_far_ahead_of_future_ci_artifacts(self):
        with patch.object(BundleArtifact, "find", return_value=None):
            select_play_bundle(dict(self.env, GITHUB_RUN_NUMBER="10000"))
        self.assertEqual(self.output()["version_code"], "1501")

    def test_historical_maximum_is_respected_even_if_not_visible_on_tracks(self):
        with patch.object(BundleArtifact, "find", return_value=None):
            select_play_bundle(dict(self.env, PLAY_MAX_VERSION_CODE="1700"))
        self.assertEqual(self.output()["version_code"], "1701")

    def test_requested_version_is_built_if_no_matching_artifact_exists(self):
        with patch.object(BundleArtifact, "find", return_value=None) as find:
            select_play_bundle(dict(self.env, REQUESTED_VERSION_CODE="1900"))
        find.assert_called_once_with(1500, 1900)
        self.assertEqual(self.output()["version_code"], "1900")

    def test_used_malformed_and_oversized_requested_versions_fail_before_search(self):
        for value in ("1500", "-1", "1\nfound=true", "2100000001"):
            with self.subTest(value=value):
                with patch.object(BundleArtifact, "find") as find, self.assertRaises(ValueError):
                    select_play_bundle(dict(self.env, REQUESTED_VERSION_CODE=value))
                find.assert_not_called()
        self.assertFalse(Path(self.env["GITHUB_OUTPUT"]).exists())

    def test_api_and_integrity_failures_do_not_silently_rebuild(self):
        for error in (RuntimeError("GitHub unavailable"), ValueError("digest mismatch")):
            with self.subTest(error=type(error)):
                with patch.object(BundleArtifact, "find", side_effect=error), \
                        patch.object(BundleArtifact, "fresh_version") as version, self.assertRaises(type(error)):
                    select_play_bundle(self.env)
                version.assert_not_called()

    def test_fallback_refuses_to_overflow_play_version_limit(self):
        with patch.object(BundleArtifact, "find", return_value=None), self.assertRaises(ValueError):
            select_play_bundle(dict(self.env, PLAY_MAX_VERSION_CODE="2100000000"))

    def test_version_probe_reads_all_tracks_and_always_discards_its_edit(self):
        session = MagicMock()
        session.post.return_value = self.response({"id": "probe"})
        session.get.return_value = self.response({"tracks": [
            {"releases": [{"versionCodes": ["100", "200"]}]},
            {"releases": [{"versionCodes": ["400"]}]},
        ]})
        session.delete.return_value = self.response({})
        self.assertEqual(play_max_version(session, "com.tofu575.glarea"), 400)
        self.assertTrue(session.delete.call_args.args[0].endswith("/edits/probe"))
        self.assertEqual(session.post.call_count, 1)

    def test_failed_version_probe_still_deletes_edit(self):
        session = MagicMock()
        session.post.return_value = self.response({"id": "probe"})
        session.get.return_value = self.response({}, status=403)
        session.delete.return_value = self.response({})
        with self.assertRaises(PlayError):
            play_max_version(session, "com.tofu575.glarea")
        session.delete.assert_called_once()

    @staticmethod
    def response(data, status=200):
        """Create a Google API response without an actual HTTP transport."""
        result = MagicMock(status_code=status)
        result.json.return_value = data
        return result


if __name__ == "__main__":
    unittest.main()
