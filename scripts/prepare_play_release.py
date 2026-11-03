"""Validate release configuration and restore secrets in runner temporary storage."""
import base64
import json
import os
from pathlib import Path


def prepare(env):
    required = (
        "BASE_VERSION_CODE", "PLAY_MAX_VERSION_CODE", "PLAY_PACKAGE_NAME",
        "ANDROID_KEYSTORE_BASE64", "ANDROID_KEY_ALIAS", "ANDROID_KEY_PASSWORD",
        "ANDROID_STORE_PASSWORD", "PLAY_SERVICE_ACCOUNT_JSON",
    )
    for name in required:
        if not env.get(name):
            raise ValueError(f"Missing GitHub Secret/Variable: {name}")
    if env["PLAY_PACKAGE_NAME"] != "com.tofu575.glarea":
        raise ValueError("Confirm Play Console package matches com.tofu575.glarea")
    numbers = [env[key] for key in (
        "BASE_VERSION_CODE", "PLAY_MAX_VERSION_CODE", "GITHUB_RUN_NUMBER", "GITHUB_RUN_ATTEMPT"
    )]
    if any(not value.isascii() or not value.isdecimal() for value in numbers):
        raise ValueError("Version settings must be non-negative decimal integers")
    base, previous, run, attempt = map(int, numbers)
    if not 1 <= attempt <= 99 or run < 1:
        raise ValueError("Use a new workflow run after attempt 99")
    requested = env.get("PLAY_VERSION_CODE", str(base + run * 100 + attempt))
    if not requested.isascii() or not requested.isdecimal():
        raise ValueError("PLAY_VERSION_CODE must be a decimal integer")
    version = int(requested)
    if not previous < version <= 2_100_000_000:
        raise ValueError("versionCode must exceed PLAY_MAX_VERSION_CODE and fit the Play limit")
    account = json.loads(env["PLAY_SERVICE_ACCOUNT_JSON"])
    if not isinstance(account, dict) or account.get("type") != "service_account" or not account.get("private_key") or not account.get("client_email"):
        raise ValueError("Invalid service account JSON")
    keystore = base64.b64decode(env["ANDROID_KEYSTORE_BASE64"], validate=True)
    if not keystore:
        raise ValueError("Empty upload keystore")
    folder = Path(env["RUNNER_TEMP"]) / "play-release"
    folder.mkdir(mode=0o700, exist_ok=False)

    def write(name, data):
        path = folder / name
        with path.open("xb") as stream:
            os.chmod(path, 0o600)
            stream.write(data)
        return str(path)

    def escape(value):
        # Java Properties uses ISO-8859-1 and interprets backslash escapes.
        encoded = value.encode("utf-16-be")
        return "".join(
            f"\\u{int.from_bytes(encoded[i:i+2], 'big'):04x}"
            for i in range(0, len(encoded), 2)
        )

    store = write("upload.jks", keystore)
    properties = write("key.properties", "\n".join(
        f"{key}={escape(value)}" for key, value in {
            "storeFile": store, "storePassword": env["ANDROID_STORE_PASSWORD"],
            "keyAlias": env["ANDROID_KEY_ALIAS"], "keyPassword": env["ANDROID_KEY_PASSWORD"],
        }.items()
    ).encode("ascii"))
    service = write("service-account.json", env["PLAY_SERVICE_ACCOUNT_JSON"].encode())
    with open(env["GITHUB_ENV"], "a") as stream:
        stream.write(f"ANDROID_KEY_PROPERTIES={properties}\n")
    with open(env["GITHUB_OUTPUT"], "a") as stream:
        stream.write(f"version_code={version}\nservice_account={service}\nkeystore={store}\n")


if __name__ == "__main__":
    try:
        prepare(os.environ)
    except (ValueError, OSError, KeyError):
        # Never include exception data: parsers may quote credentials.
        raise SystemExit("Release setup failed. Check required Variables, Secrets, package and version settings.") from None
