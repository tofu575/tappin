import base64
import json
from pathlib import Path
import tempfile
import unittest
from prepare_play_release import prepare


class ReleaseSetupTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.env = dict(
            BASE_VERSION_CODE="1000", PLAY_MAX_VERSION_CODE="1000",
            PLAY_PACKAGE_NAME="com.tofu575.tappin", GITHUB_RUN_NUMBER="2",
            GITHUB_RUN_ATTEMPT="1", RUNNER_TEMP=self.temp.name,
            GITHUB_ENV=f"{self.temp.name}/env", GITHUB_OUTPUT=f"{self.temp.name}/output",
            ANDROID_KEYSTORE_BASE64=base64.b64encode(b"dummy-keystore").decode(),
            ANDROID_KEY_ALIAS="upload", ANDROID_KEY_PASSWORD="space :\\\n秘密😀",
            ANDROID_STORE_PASSWORD="password",
            PLAY_SERVICE_ACCOUNT_JSON=json.dumps(dict(type="service_account", private_key="dummy", client_email="test@example.invalid")),
        )

    def test_restore_and_attempt_version(self):
        prepare(self.env)
        self.assertIn("version_code=1201", Path(self.env["GITHUB_OUTPUT"]).read_text())
        folder = Path(self.temp.name) / "play-release"
        self.assertEqual((folder / "upload.jks").read_bytes(), b"dummy-keystore")
        self.assertEqual((folder / "key.properties").stat().st_mode & 0o777, 0o600)
        properties = (folder / "key.properties").read_text()
        self.assertIn("\\ud83d\\ude00", properties)
        self.assertNotIn("秘密", properties)

    def test_rejects_bad_config_before_writing(self):
        for key, value in (
            ("PLAY_MAX_VERSION_CODE", "1201"), ("BASE_VERSION_CODE", "2100000000"),
            ("GITHUB_RUN_ATTEMPT", "100"), ("GITHUB_RUN_ATTEMPT", "0"),
            ("BASE_VERSION_CODE", "-1"), ("PLAY_PACKAGE_NAME", "other.app"),
            ("PLAY_SERVICE_ACCOUNT_JSON", "{}"), ("ANDROID_KEYSTORE_BASE64", "!invalid!"),
            ("ANDROID_STORE_PASSWORD", ""),
        ):
            with self.subTest(key=key, value=value):
                env = dict(self.env, **{key: value})
                with self.assertRaises(ValueError):
                    prepare(env)
                self.assertFalse((Path(self.temp.name) / "play-release").exists())

    def test_selected_ci_version_is_preserved_and_keystore_is_exposed(self):
        self.env["PLAY_VERSION_CODE"] = "1500"
        prepare(self.env)
        output = Path(self.env["GITHUB_OUTPUT"]).read_text()
        self.assertIn("version_code=1500", output)
        self.assertIn(f"keystore={self.temp.name}/play-release/upload.jks", output)

    def test_rejects_invalid_selected_ci_version(self):
        for version in ("1000", "2100000001", "-1", "1201\nfound=true"):
            with self.subTest(version=version), self.assertRaises(ValueError):
                prepare(dict(self.env, PLAY_VERSION_CODE=version))
        self.assertFalse((Path(self.temp.name) / "play-release").exists())

    def test_retry_increments_version(self):
        self.env["GITHUB_RUN_ATTEMPT"] = "2"
        prepare(self.env)
        self.assertIn("version_code=1202", Path(self.env["GITHUB_OUTPUT"]).read_text())


if __name__ == "__main__":
    unittest.main()
