import hashlib
from contextlib import redirect_stdout
import io
import json
import os
from pathlib import Path
import shutil
import tempfile
import unittest
from unittest.mock import patch
import zipfile

from bundle_artifact import BundleArtifact


class BundleArtifactTest(unittest.TestCase):
    """Exercise actual packaging and artifact retrieval without GitHub network calls."""

    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        previous = Path.cwd()
        os.chdir(self.temp.name)
        self.addCleanup(os.chdir, previous)
        self.sha = "a" * 40
        self.git = patch("bundle_artifact.subprocess.check_output", return_value=self.sha + "\n")
        self.git.start()
        self.addCleanup(self.git.stop)
        Path("pubspec.yaml").write_text('name: glarea\nversion: 0.1.0+1\n')
        Path(".flutter-version").write_text("3.44.9\n")
        self.env = dict(TARGET_SHA=self.sha, BASE_VERSION_CODE="1000", GITHUB_RUN_NUMBER="4",
                        GITHUB_RUN_ATTEMPT="2", GITHUB_RUN_ID="99", GITHUB_REPOSITORY="tofu575/glarea",
                        RUNNER_TEMP=self.temp.name, GITHUB_OUTPUT=f"{self.temp.name}/output",
                        BUNDLE_VERSION_CODE="1402")
        self.bundle = BundleArtifact(self.env)
        self.run = dict(id=99, run_number=4, run_attempt=2, head_sha=self.sha,
                        path=BundleArtifact.WORKFLOW, event="push", conclusion="success",
                        head_repository=dict(full_name="tofu575/glarea"))

    def archive(self, metadata_updates=None, extra=None):
        """Package a minimal unsigned bundle using the production metadata writer."""
        contents = io.BytesIO()
        with zipfile.ZipFile(contents, "w") as archive:
            archive.writestr("BundleConfig.pb", b"config")
            archive.writestr("base/manifest/AndroidManifest.xml", b"manifest")
        self.aab = contents.getvalue()
        path = Path("build/app/outputs/bundle/release/app-release.aab")
        path.parent.mkdir(parents=True)
        path.write_bytes(self.aab)
        self.bundle.pack()
        metadata = json.loads((self.bundle.folder / "release.json").read_text())
        metadata.update(metadata_updates or {})
        contents = io.BytesIO()
        with zipfile.ZipFile(contents, "w") as archive:
            archive.writestr("app-release.aab", self.aab)
            archive.writestr("release.json", json.dumps(metadata))
            for name, value in (extra or {}).items():
                archive.writestr(name, value)
        blob = contents.getvalue()
        self.artifact = dict(id=7, name=self.bundle.name(1402), expired=False,
                             digest="sha256:" + hashlib.sha256(blob).hexdigest())
        shutil.rmtree(self.bundle.folder)
        return blob

    def test_version_is_fixed_before_build_and_metadata_round_trips(self):
        self.bundle.configure()
        self.assertIn(f"artifact_name=glarea-aab-0.1.0-1402-{self.sha}", Path(self.env["GITHUB_OUTPUT"]).read_text())
        blob = self.archive()
        self.assertEqual(self.bundle.unpack(blob, self.artifact, self.run), 1402)
        self.assertEqual((self.bundle.folder / "app-release.aab").read_bytes(), self.aab)

    def test_wrong_checkout_and_invalid_or_overflowed_version_are_rejected(self):
        for changes in ({"TARGET_SHA": "b" * 40}, {"BASE_VERSION_CODE": "-1"}):
            with self.subTest(changes=changes), self.assertRaises(ValueError):
                BundleArtifact(dict(self.env, **changes))
        for minimum in (2_100_000_000,):
            with self.assertRaises(ValueError):
                self.bundle.fresh_version(minimum)
        self.bundle.env = dict(self.env, GITHUB_RUN_ATTEMPT="100")
        with self.assertRaises(ValueError):
            self.bundle.version()

    def test_corrupt_archive_digest_never_extracts(self):
        blob = self.archive()
        with self.assertRaisesRegex(ValueError, "digest"):
            self.bundle.unpack(blob + b"changed", self.artifact, self.run)
        self.assertFalse(self.bundle.folder.exists())

    def test_wrong_source_package_version_and_ci_provenance_never_extract(self):
        blob = self.archive()
        with zipfile.ZipFile(io.BytesIO(blob)) as archive:
            metadata = json.loads(archive.read("release.json"))
        for changes in ({"source_sha": "b" * 40}, {"package": "other.app"}, {"version_code": 999},
                        {"version_name": "9.9.9"}, {"ci_run_id": 100}, {"ci_run_attempt": 1},
                        {"base_version_code": 0}, {"flutter_version": "other"}, {"bundle_sha256": "0" * 64}):
            with self.subTest(changes=changes):
                content = io.BytesIO()
                with zipfile.ZipFile(content, "w") as archive:
                    archive.writestr("app-release.aab", self.aab)
                    archive.writestr("release.json", json.dumps(dict(metadata, **changes)))
                changed = content.getvalue()
                artifact = dict(self.artifact, digest="sha256:" + hashlib.sha256(changed).hexdigest())
                with self.assertRaises(ValueError):
                    self.bundle.unpack(changed, artifact, self.run)
                self.assertFalse(self.bundle.folder.exists())

    def test_unexpected_archive_paths_are_not_extracted(self):
        blob = self.archive(extra={"../outside": "unsafe"})
        with self.assertRaisesRegex(ValueError, "contents"):
            self.bundle.unpack(blob, self.artifact, self.run)
        self.assertFalse(Path("outside").exists())

    def test_cache_hit_reuses_exact_bundle_bytes(self):
        blob = self.archive()
        with patch.object(BundleArtifact, "api", side_effect=[{"workflow_runs": [self.run]},
                          {"artifacts": [self.artifact]}, blob]):
            self.assertEqual(self.bundle.find(1300), 1402)
        self.assertEqual((self.bundle.folder / "app-release.aab").read_bytes(), self.aab)

    def test_feature_push_bundle_is_reused_instead_of_a_newer_pr_merge_bundle(self):
        blob = self.archive()
        branch_run = dict(self.run, head_branch="feature/list-input-experience")
        pr_run = dict(branch_run, id=100, run_number=5, event="pull_request")
        log = io.StringIO()
        with patch.object(BundleArtifact, "api", side_effect=[{"workflow_runs": [pr_run, branch_run]},
                          {"artifacts": [self.artifact]}, blob]) as api, redirect_stdout(log):
            self.assertEqual(self.bundle.find(1300), 1402)
        self.assertIn("Skip CI run 100: event=pull_request", log.getvalue())
        self.assertIn("Verified CI artifact 7", log.getvalue())
        self.assertIn("/runs/99/artifacts", api.call_args_list[1].args[0])
        self.assertEqual((self.bundle.folder / "app-release.aab").read_bytes(), self.aab)

    def test_only_pr_ci_explains_why_manual_branch_release_cannot_reuse_it(self):
        log = io.StringIO()
        with patch.object(BundleArtifact, "api", return_value={"workflow_runs": [
                dict(self.run, event="pull_request")
        ]}) as api, redirect_stdout(log):
            self.assertIsNone(self.bundle.find(0))
        self.assertEqual(api.call_count, 1)
        self.assertIn("PR merge artifacts are not branch-source bundles", log.getvalue())
        self.assertIn("Run Android checks on the selected branch", log.getvalue())
        self.assertFalse(self.bundle.folder.exists())

    def test_cache_miss_reports_source_expiry_used_and_requested_version_reasons(self):
        self.archive()
        cases = [
            (dict(self.artifact, expired=True), 0, None, "expired"),
            (dict(self.artifact, name=self.artifact["name"].replace(self.sha, "b" * 40)),
             0, None, "source SHA or versionName differs"),
            (self.artifact, 1402, None, "versionCode 1402 <= used maximum 1402"),
            (self.artifact, 0, 1403, "versionCode 1402 != requested 1403"),
        ]
        for artifact, minimum, requested, reason in cases:
            with self.subTest(reason=reason):
                log = io.StringIO()
                with patch.object(BundleArtifact, "api", side_effect=[{"workflow_runs": [self.run]},
                                  {"artifacts": [artifact]}]) as api, redirect_stdout(log):
                    self.assertIsNone(self.bundle.find(minimum, requested))
                self.assertEqual(api.call_count, 2)
                self.assertIn(reason, log.getvalue())
                self.assertFalse(self.bundle.folder.exists())

    def test_no_runs_expiry_stale_or_different_requested_version_are_cache_misses(self):
        self.archive()
        with patch.object(BundleArtifact, "api", return_value={"workflow_runs": []}):
            self.assertIsNone(self.bundle.find(0))
        for expired, minimum, requested in ((True, 0, None), (False, 1402, None), (False, 0, 1403)):
            artifact = dict(self.artifact, expired=expired)
            with self.subTest(expired=expired, minimum=minimum, requested=requested):
                with patch.object(BundleArtifact, "api", side_effect=[{"workflow_runs": [self.run]},
                                  {"artifacts": [artifact]}]) as api:
                    self.assertIsNone(self.bundle.find(minimum, requested))
                    self.assertEqual(api.call_count, 2)

    def test_wrong_commit_fork_failed_and_pr_runs_are_not_trusted(self):
        for changes in ({"head_sha": "b" * 40}, {"event": "pull_request"},
                        {"conclusion": "failure"}, {"path": "another.yml"},
                        {"head_repository": {"full_name": "fork/glarea"}}):
            with self.subTest(changes=changes):
                with patch.object(BundleArtifact, "api", return_value={"workflow_runs": [dict(self.run, **changes)]}):
                    self.assertEqual(self.bundle.runs(), [])

    def test_explicit_trigger_run_is_used_without_searching_other_commits(self):
        self.bundle.env = dict(self.env, CI_RUN_ID="99")
        with patch.object(BundleArtifact, "api", return_value=self.run) as api:
            self.assertEqual(self.bundle.runs(), [self.run])
            api.assert_called_once_with("repos/tofu575/glarea/actions/runs/99")

    def test_artifact_listing_is_paginated(self):
        blob = self.archive()
        expired = [dict(self.artifact, id=index + 100, expired=True) for index in range(100)]
        with patch.object(BundleArtifact, "api", side_effect=[{"workflow_runs": [self.run]},
                          {"artifacts": expired}, {"artifacts": [self.artifact]}, blob]) as api:
            self.assertEqual(self.bundle.find(0), 1402)
            self.assertIn("page=2", api.call_args_list[2].args[0])

    def test_authentication_errors_are_not_treated_as_cache_misses(self):
        result = type("Result", (), dict(returncode=1, stderr=b"gh: forbidden (HTTP 403)"))()
        with patch("bundle_artifact.subprocess.run", return_value=result), self.assertRaises(RuntimeError):
            self.bundle.api("repos/tofu575/glarea/actions/artifacts/7/zip", binary=True, missing=True)

    def test_expired_download_can_fall_back(self):
        result = type("Result", (), dict(returncode=1, stderr=b"gh: gone (HTTP 410)"))()
        with patch("bundle_artifact.subprocess.run", return_value=result):
            self.assertIsNone(self.bundle.api("repos/tofu575/glarea/actions/artifacts/7/zip", binary=True, missing=True))


if __name__ == "__main__":
    unittest.main()
