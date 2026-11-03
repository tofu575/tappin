"""Upload one signed AAB to the Play internal track using Google's official auth SDK."""
import argparse
from pathlib import Path
import sys
from urllib.parse import quote, urlparse



API = "https://androidpublisher.googleapis.com/androidpublisher/v3/applications"
UPLOAD = "https://androidpublisher.googleapis.com/upload/androidpublisher/v3/applications"


class PlayError(Exception):
    pass


def checked(response, stage):
    if not 200 <= response.status_code < 300:
        # Do not print request headers/bodies or credential-bearing exception objects.
        raise PlayError(f"{stage}: Google Play API returned HTTP {response.status_code}")
    return response


def upload(session, package, bundle, expected_version):
    base = f"{API}/{quote(package, safe='')}"
    edit = checked(session.post(f"{base}/edits", json={}, timeout=60), "Create edit").json()["id"]
    committed = False
    try:
        # Check currently visible tracks as well as the historical maximum supplied by the owner.
        tracks = checked(session.get(f"{base}/edits/{edit}/tracks", timeout=60), "Read tracks").json()
        used = [int(code) for track in tracks.get("tracks", [])
                for release in track.get("releases", []) for code in release.get("versionCodes", [])]
        if used and expected_version <= max(used):
            raise PlayError("versionCode must exceed all currently visible track versions; update BASE_VERSION_CODE")
        size = bundle.stat().st_size
        start = checked(session.post(
            f"{UPLOAD}/{quote(package, safe='')}/edits/{edit}/bundles",
            params={"uploadType": "resumable"}, json={},
            headers={"X-Upload-Content-Type": "application/octet-stream", "X-Upload-Content-Length": str(size)},
            timeout=60,
        ), "Start bundle upload")
        location = start.headers.get("Location", "")
        parsed = urlparse(location)
        if parsed.scheme != "https" or parsed.username or parsed.password or parsed.port not in (None, 443) or not (parsed.hostname or "").endswith(".googleapis.com"):
            raise PlayError("Google returned an unexpected upload endpoint")
        with bundle.open("rb") as stream:
            result = checked(session.put(location, data=stream, headers={
                "Content-Type": "application/octet-stream", "Content-Length": str(size)
            }, timeout=900, allow_redirects=False), "Upload bundle").json()
        if int(result["versionCode"]) != expected_version:
            raise PlayError("Uploaded bundle versionCode differs from the expected version")
        checked(session.put(f"{base}/edits/{edit}/tracks/internal", json={
            "track": "internal", "releases": [{"versionCodes": [str(expected_version)], "status": "completed"}]
        }, timeout=60), "Update internal track")
        checked(session.post(f"{base}/edits/{edit}:validate", json={}, timeout=60), "Validate edit")
        checked(session.post(f"{base}/edits/{edit}:commit", json={}, timeout=120), "Commit edit")
        committed = True
        print(f"Published versionCode {expected_version} to internal testing.")
    finally:
        if not committed:
            try:
                session.delete(f"{base}/edits/{edit}", timeout=30)
            except Exception:
                pass  # Preserve the original failure and never log authentication data.


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--credentials", required=True)
    parser.add_argument("--package", required=True, choices=["com.tofu575.tappin"])
    parser.add_argument("--bundle", type=Path, required=True)
    parser.add_argument("--version-code", type=int, required=True)
    args = parser.parse_args()
    try:
        from google.auth.transport.requests import AuthorizedSession
        from google.oauth2 import service_account

        credentials = service_account.Credentials.from_service_account_file(
            args.credentials, scopes=["https://www.googleapis.com/auth/androidpublisher"])
        with AuthorizedSession(credentials) as session:
            upload(session, args.package, args.bundle, args.version_code)
    except PlayError as error:
        print(str(error), file=sys.stderr)
        return 1
    except Exception:
        print("Play upload failed (authentication, transport, or response error). Check account/API setup; credentials are not logged.", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
