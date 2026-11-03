"""Validate TestFlight configuration and prepare temporary signing credentials."""
import base64
from datetime import datetime, timezone
import os
from pathlib import Path
import plistlib
import re
import subprocess


def prepare(env):
    """Restore credentials, validate the distribution profile and configure signing."""
    required = (
        "APPLE_TEAM_ID", "APP_STORE_CONNECT_KEY_ID", "APP_STORE_CONNECT_ISSUER_ID",
        "APP_STORE_CONNECT_PRIVATE_KEY", "IOS_DISTRIBUTION_CERTIFICATE_BASE64",
        "IOS_DISTRIBUTION_CERTIFICATE_PASSWORD", "IOS_PROVISIONING_PROFILE_BASE64",
        "TESTFLIGHT_BUILD_OFFSET", "GITHUB_RUN_NUMBER", "GITHUB_RUN_ATTEMPT",
        "RUNNER_TEMP", "GITHUB_WORKSPACE", "GITHUB_OUTPUT",
    )
    for name in required:
        if not env.get(name):
            raise ValueError(f"Missing GitHub Secret/Variable: {name}")
    for name in ("APPLE_TEAM_ID", "APP_STORE_CONNECT_KEY_ID"):
        if not re.fullmatch(r"[A-Z0-9]{10}", env[name]):
            raise ValueError(f"Invalid {name}")
    if not re.fullmatch(r"[a-fA-F0-9]{8}(?:-[a-fA-F0-9]{4}){3}-[a-fA-F0-9]{12}", env["APP_STORE_CONNECT_ISSUER_ID"]):
        raise ValueError("Invalid App Store Connect issuer ID")
    numbers = [env[name] for name in (
        "TESTFLIGHT_BUILD_OFFSET", "GITHUB_RUN_NUMBER", "GITHUB_RUN_ATTEMPT",
    )]
    if any(not re.fullmatch(r"[0-9]+", value) for value in numbers):
        raise ValueError("Build settings must be non-negative decimal integers")
    offset, run, attempt = map(int, numbers)
    if run < 1 or not 1 <= offset + run <= 9999 or not 1 <= attempt <= 99:
        raise ValueError("Build number exceeds Apple's component limits")
    private_key = env["APP_STORE_CONNECT_PRIVATE_KEY"].strip()
    if not private_key.startswith("-----BEGIN PRIVATE KEY-----\n") or not private_key.endswith("-----END PRIVATE KEY-----"):
        raise ValueError("Expected the contents of an App Store Connect .p8 key")
    certificate = base64.b64decode(env["IOS_DISTRIBUTION_CERTIFICATE_BASE64"], validate=True)
    profile = base64.b64decode(env["IOS_PROVISIONING_PROFILE_BASE64"], validate=True)
    if not certificate or not profile:
        raise ValueError("Empty certificate or provisioning profile")
    root = Path(env["GITHUB_WORKSPACE"])
    project = (root / "ios/Runner.xcodeproj/project.pbxproj").read_text()
    if re.findall(r"PRODUCT_BUNDLE_IDENTIFIER = ([^;]+);", project).count("com.tofu575.tappin") != 3:
        raise ValueError("Confirm the Runner bundle identifier is com.tofu575.tappin")
    folder = Path(env["RUNNER_TEMP"]) / "testflight-release"
    folder.mkdir(mode=0o700, exist_ok=False)

    def write(name, contents):
        """Write a credential without making it readable by other users."""
        path = folder / name
        with path.open("xb") as stream:
            os.chmod(path, 0o600)
            stream.write(contents)
        return path

    write("distribution.p12", certificate)
    profile_path = write("distribution.mobileprovision", profile)
    decoded = subprocess.run(
        ["security", "cms", "-D", "-i", str(profile_path)],
        check=True, capture_output=True,
    ).stdout
    provision = plistlib.loads(decoded)
    entitlements = provision.get("Entitlements", {})
    team = env["APPLE_TEAM_ID"]
    expires = provision.get("ExpirationDate")
    uuid = provision.get("UUID", "")
    if (
        not re.fullmatch(r"[a-fA-F0-9-]{36}", uuid)
        or provision.get("TeamIdentifier") != [team]
        or entitlements.get("application-identifier") != f"{team}.com.tofu575.tappin"
        or entitlements.get("get-task-allow") is not False
        or "ProvisionedDevices" in provision
        or provision.get("ProvisionsAllDevices", False)
        or not provision.get("DeveloperCertificates")
        or not isinstance(expires, datetime)
        or expires.replace(tzinfo=timezone.utc) <= datetime.now(timezone.utc)
    ):
        raise ValueError("Use an unexpired App Store profile for this team and app")
    (folder / "private_keys").mkdir(mode=0o700)
    write(f"private_keys/AuthKey_{env['APP_STORE_CONNECT_KEY_ID']}.p8", (private_key + "\n").encode())
    write("ExportOptions.plist", plistlib.dumps({
        "method": "app-store-connect", "destination": "export",
        "teamID": team, "signingStyle": "manual",
        "signingCertificate": "Apple Distribution", "manageAppVersionAndBuildNumber": False,
        "provisioningProfiles": {"com.tofu575.tappin": uuid},
        "uploadSymbols": True,
    }))
    # Only this ephemeral checkout receives the signing configuration.
    with (root / "ios/Flutter/Release.xcconfig").open("a") as stream:
        stream.write(
            f"\nDEVELOPMENT_TEAM = {team}\nCODE_SIGN_STYLE = Manual\n"
            f"CODE_SIGN_IDENTITY = Apple Distribution\nPROVISIONING_PROFILE_SPECIFIER = {uuid}\n"
        )
    with open(env["GITHUB_OUTPUT"], "a") as stream:
        stream.write(f"profile_uuid={uuid}\nbuild_number={offset + run}.{attempt}.0\n")


if __name__ == "__main__":
    try:
        prepare(os.environ)
    except (ValueError, OSError, KeyError, TypeError, subprocess.CalledProcessError, plistlib.InvalidFileException):
        # Parser and command errors can contain private credential contents.
        raise SystemExit("TestFlight setup failed. Check Apple Secrets, Variables and the distribution profile.") from None
