"""Exercise credential validation without Apple credentials or macOS tools."""
import base64
from datetime import datetime, timedelta
from pathlib import Path
import plistlib
import shutil
import subprocess
import tempfile
import unittest
from unittest.mock import patch

from prepare_testflight_release import prepare


class TestFlightSetupTest(unittest.TestCase):
    """Check profile isolation, build numbering and invalid release configuration."""

    def setUp(self):
        """Create a minimal checkout and a decoded App Store distribution profile."""
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        (self.root / "ios/Flutter").mkdir(parents=True)
        (self.root / "ios/Flutter/Release.xcconfig").write_text('#include "Generated.xcconfig"\n')
        (self.root / "ios/Runner.xcodeproj").mkdir()
        (self.root / "ios/Runner.xcodeproj/project.pbxproj").write_text(
            "PRODUCT_BUNDLE_IDENTIFIER = com.tofu575.glarea;\n" * 3,
        )
        self.env = dict(
            APPLE_TEAM_ID="ABCDEFGHIJ", APP_STORE_CONNECT_KEY_ID="0123456789",
            APP_STORE_CONNECT_ISSUER_ID="12345678-1234-1234-1234-123456789abc",
            APP_STORE_CONNECT_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\ntest\n-----END PRIVATE KEY-----",
            IOS_DISTRIBUTION_CERTIFICATE_BASE64=base64.b64encode(b"certificate").decode(),
            IOS_DISTRIBUTION_CERTIFICATE_PASSWORD="password",
            IOS_PROVISIONING_PROFILE_BASE64=base64.b64encode(b"profile").decode(),
            TESTFLIGHT_BUILD_OFFSET="100", GITHUB_RUN_NUMBER="12", GITHUB_RUN_ATTEMPT="1",
            RUNNER_TEMP=str(self.root), GITHUB_WORKSPACE=str(self.root),
            GITHUB_OUTPUT=str(self.root / "output"),
        )
        self.profile = {
            "UUID": "12345678-1234-1234-1234-123456789abc", "TeamIdentifier": ["ABCDEFGHIJ"],
            "ExpirationDate": datetime.now() + timedelta(days=10),
            "Entitlements": {"application-identifier": "ABCDEFGHIJ.com.tofu575.glarea", "get-task-allow": False},
            "DeveloperCertificates": [b"certificate"],
        }

    def run_prepare(self, profile=None):
        """Supply the result of macOS security's profile decoding."""
        decoded = plistlib.dumps(self.profile if profile is None else profile)
        with patch("prepare_testflight_release.subprocess.run") as command:
            command.return_value.stdout = decoded
            prepare(self.env)
            self.assertEqual(command.call_args.args[0][:4], ["security", "cms", "-D", "-i"])

    def test_restores_private_credentials_and_signing_configuration(self):
        """Export options must retain the build number and select the matching profile."""
        self.run_prepare()
        folder = self.root / "testflight-release"
        for name in ("distribution.p12", "distribution.mobileprovision", "private_keys/AuthKey_0123456789.p8"):
            self.assertEqual((folder / name).stat().st_mode & 0o777, 0o600)
        options = plistlib.loads((folder / "ExportOptions.plist").read_bytes())
        self.assertEqual(options["method"], "app-store-connect")
        self.assertFalse(options["manageAppVersionAndBuildNumber"])
        self.assertEqual(options["provisioningProfiles"], {"com.tofu575.glarea": self.profile["UUID"]})
        self.assertIn("build_number=112.1.0\n", (self.root / "output").read_text())
        config = (self.root / "ios/Flutter/Release.xcconfig").read_text()
        self.assertIn("CODE_SIGN_STYLE = Manual", config)
        self.assertIn(f"PROVISIONING_PROFILE_SPECIFIER = {self.profile['UUID']}", config)

    def test_retry_uses_a_new_build_number(self):
        """A workflow retry must not reuse a TestFlight build number."""
        self.env["GITHUB_RUN_ATTEMPT"] = "2"
        self.run_prepare()
        self.assertIn("build_number=112.2.0\n", (self.root / "output").read_text())

    def test_invalid_settings_fail_before_writing_credentials(self):
        """Reject missing secrets, malformed IDs and unsupported build numbers."""
        for name, value in (
            ("APPLE_TEAM_ID", "BAD\nCODE_SIGN_STYLE = Automatic"),
            ("APP_STORE_CONNECT_KEY_ID", "../key"),
            ("APP_STORE_CONNECT_ISSUER_ID", "bad"),
            ("APP_STORE_CONNECT_PRIVATE_KEY", "bad"),
            ("IOS_DISTRIBUTION_CERTIFICATE_BASE64", "!invalid!"),
            ("IOS_PROVISIONING_PROFILE_BASE64", ""),
            ("IOS_DISTRIBUTION_CERTIFICATE_PASSWORD", ""),
            ("TESTFLIGHT_BUILD_OFFSET", "-1"), ("TESTFLIGHT_BUILD_OFFSET", "10000"),
            ("GITHUB_RUN_NUMBER", "0"), ("GITHUB_RUN_ATTEMPT", "0"),
            ("GITHUB_RUN_ATTEMPT", "100"), ("GITHUB_RUN_ATTEMPT", "1\nbuild_number=1"),
        ):
            with self.subTest(name=name, value=value), self.assertRaises(ValueError):
                prepare(dict(self.env, **{name: value}))
            self.assertFalse((self.root / "testflight-release").exists())

    def test_rejects_invalid_distribution_profiles(self):
        """Prevent signing another app or using development, ad hoc or expired profiles."""
        invalid = (
            dict(self.profile, TeamIdentifier=["OTHERTEAM1"]),
            dict(self.profile, Entitlements={"application-identifier": "ABCDEFGHIJ.other.app", "get-task-allow": False}),
            dict(self.profile, Entitlements={"application-identifier": "ABCDEFGHIJ.com.tofu575.glarea", "get-task-allow": True}),
            dict(self.profile, ProvisionedDevices=["device"]),
            dict(self.profile, ProvisionsAllDevices=True),
            dict(self.profile, ExpirationDate=datetime.now() - timedelta(days=1)),
            dict(self.profile, DeveloperCertificates=[]),
            dict(self.profile, UUID="../profile"),
        )
        for profile in invalid:
            with self.subTest(profile=profile), self.assertRaises(ValueError):
                self.run_prepare(profile)
            # The workflow's always() step removes restored credentials on failure.
            shutil.rmtree(self.root / "testflight-release")
            self.assertFalse((self.root / "output").exists())
            self.assertNotIn("CODE_SIGN_STYLE", (self.root / "ios/Flutter/Release.xcconfig").read_text())

    def test_profile_decoder_errors_propagate(self):
        """A failed security command must stop the release."""
        with patch("prepare_testflight_release.subprocess.run", side_effect=subprocess.CalledProcessError(1, "security")):
            with self.assertRaises(subprocess.CalledProcessError):
                prepare(self.env)


if __name__ == "__main__":
    unittest.main()
