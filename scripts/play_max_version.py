"""Read currently visible Play version codes before choosing a deployable bundle."""
from upload_play import API, checked


def play_max_version(session, package):
    """Read every track in a temporary edit and always discard the edit."""
    if package != "com.tofu575.glarea":
        raise ValueError("Unexpected Play package")
    base = f"{API}/{package}/edits"
    edit = checked(session.post(base, json={}, timeout=60), "Create version-check edit").json()["id"]
    try:
        tracks = checked(session.get(f"{base}/{edit}/tracks", timeout=60), "Read release versions").json()
        return max((int(code) for track in tracks.get("tracks", [])
                    for release in track.get("releases", [])
                    for code in release.get("versionCodes", [])), default=0)
    finally:
        checked(session.delete(f"{base}/{edit}", timeout=30), "Discard version-check edit")
