"""Prefer a validated CI bundle and allocate a fresh version only when rebuilding."""
import json
import os
from pathlib import Path

from bundle_artifact import BundleArtifact
from play_max_version import play_max_version


def select_play_bundle(env):
    """Select the exact source/version artifact, checking Play before any Flutter setup."""
    from google.auth.transport.requests import AuthorizedSession
    from google.oauth2 import service_account

    artifact = BundleArtifact(env)
    if env["PLAY_PACKAGE_NAME"] != artifact.PACKAGE:
        raise ValueError("Unexpected Play package")
    if env.get("AUTO_DEPLOY") == "true":
        head = artifact.api(f"repos/{env['GITHUB_REPOSITORY']}/git/ref/heads/main")
        if head["object"]["sha"] != artifact.sha:
            artifact.output(deploy="false")
            print("Skip obsolete automatic deployment: source is no longer main HEAD.")
            return
    previous = artifact.number(env["PLAY_MAX_VERSION_CODE"])
    account = json.loads(env["PLAY_SERVICE_ACCOUNT_JSON"])
    credentials = service_account.Credentials.from_service_account_info(
        account, scopes=["https://www.googleapis.com/auth/androidpublisher"])
    with AuthorizedSession(credentials) as session:
        minimum = max(previous, play_max_version(session, artifact.PACKAGE))
    raw = env.get("REQUESTED_VERSION_CODE", "")
    requested = artifact.number(raw) if raw else None
    if requested is not None and not minimum < requested <= artifact.LIMIT:
        raise ValueError("Requested versionCode must exceed used versions and fit the Play limit")
    cached = artifact.find(minimum, requested)
    version = cached if cached is not None else requested if requested is not None else artifact.fresh_version(minimum)
    bundle = artifact.folder / "app-release.aab" if cached is not None else Path("build/app/outputs/bundle/release/app-release.aab")
    artifact.output(deploy="true", found="true" if cached is not None else "false", version_code=version,
                    version_name=artifact.version_name, bundle=bundle)
    print(f"{'Reuse verified CI artifact' if cached is not None else 'No usable CI artifact; build from source'}: "
          f"{artifact.version_name} ({version}), commit {artifact.sha}")


if __name__ == "__main__":
    try:
        select_play_bundle(os.environ)
    except Exception:
        raise SystemExit("Bundle selection failed. Check GitHub artifact access, Play permissions, and version settings.") from None
