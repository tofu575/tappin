"""Create and retrieve immutable, unsigned Android bundle artifacts."""
import hashlib
import io
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import zipfile


class BundleArtifact:
    """Bind an unsigned bundle to its source commit, version, and successful CI run."""

    PACKAGE = "com.tofu575.glarea"
    WORKFLOW = ".github/workflows/android-check.yml"
    LIMIT = 2_100_000_000

    def __init__(self, env):
        """Read the checked-out source and public version settings."""
        self.env = env
        self.sha = subprocess.check_output(["git", "rev-parse", "HEAD"], text=True).strip()
        if not re.fullmatch(r"[0-9a-f]{40}", self.sha) or self.sha != env["TARGET_SHA"]:
            raise ValueError("Checkout does not match the deployment source")
        match = re.search(r'^version:\s*[\'"]?([0-9]+\.[0-9]+\.[0-9]+(?:-[A-Za-z0-9.-]+)?)\+[0-9]+[\'"]?\s*$',
                          Path("pubspec.yaml").read_text(), re.MULTILINE)
        if not match:
            raise ValueError("pubspec.yaml must contain versionName+buildNumber")
        self.version_name = match[1]
        self.flutter = Path(".flutter-version").read_text().strip()
        self.base = self.number(env["BASE_VERSION_CODE"])
        self.folder = Path(env["RUNNER_TEMP"]) / "android-bundle"

    @staticmethod
    def number(value):
        """Validate an integer before using it in a version or workflow output."""
        value = str(value)
        if not value.isascii() or not value.isdecimal():
            raise ValueError("Expected a non-negative decimal integer")
        return int(value)

    def version(self):
        """Allocate the immutable CI version before building."""
        run = self.number(self.env["GITHUB_RUN_NUMBER"])
        attempt = self.number(self.env["GITHUB_RUN_ATTEMPT"])
        if run < 1 or not 1 <= attempt <= 99:
            raise ValueError("Use a new workflow run after attempt 99")
        version = self.base + run * 100 + attempt
        if version > self.LIMIT:
            raise ValueError("versionCode exceeds the Play limit")
        return version

    def fresh_version(self, minimum):
        """Rebuild just above the used maximum without a separate CD counter jump."""
        version = max(self.base, minimum) + 1
        if version > self.LIMIT:
            raise ValueError("versionCode exceeds the Play limit")
        return version

    def output(self, **values):
        """Expose validated, single-line values to following workflow steps."""
        with open(self.env["GITHUB_OUTPUT"], "a") as stream:
            for key, value in values.items():
                if "\n" in str(value) or "\r" in str(value):
                    raise ValueError("Invalid workflow output")
                stream.write(f"{key}={value}\n")

    def name(self, version):
        """Include both the release version and exact source commit in the artifact name."""
        return f"glarea-aab-{self.version_name}-{version}-{self.sha}"

    def configure(self):
        """Choose the immutable version before CI builds the bundle."""
        version = self.version()
        self.output(version_code=version, artifact_name=self.name(version))

    @staticmethod
    def unsigned(bundle):
        """Reject non-bundles and already-signed archives before caching or signing."""
        with zipfile.ZipFile(io.BytesIO(bundle)) as archive:
            names = archive.namelist()
            if not {"BundleConfig.pb", "base/manifest/AndroidManifest.xml"}.issubset(names):
                raise ValueError("Not an Android App Bundle")
            if any(name.upper().startswith("META-INF/") and
                   name.upper().endswith((".SF", ".RSA", ".DSA", ".EC")) for name in names):
                raise ValueError("CI artifacts must be unsigned")

    def pack(self):
        """Store only the unsigned AAB and its hash-bound release metadata."""
        version = self.number(self.env["BUNDLE_VERSION_CODE"])
        if version != self.version():
            raise ValueError("Build version differs from the allocated CI version")
        bundle = Path("build/app/outputs/bundle/release/app-release.aab").read_bytes()
        self.unsigned(bundle)
        metadata = dict(schema=1, source_sha=self.sha, package=self.PACKAGE,
                        version_name=self.version_name, version_code=version,
                        base_version_code=self.base, flutter_version=self.flutter,
                        ci_run_id=self.number(self.env["GITHUB_RUN_ID"]),
                        ci_run_number=self.number(self.env["GITHUB_RUN_NUMBER"]),
                        ci_run_attempt=self.number(self.env["GITHUB_RUN_ATTEMPT"]),
                        bundle_sha256=hashlib.sha256(bundle).hexdigest())
        self.folder.mkdir(parents=True, exist_ok=False)
        (self.folder / "app-release.aab").write_bytes(bundle)
        (self.folder / "release.json").write_text(json.dumps(metadata, indent=2) + "\n")
        self.output(artifact_directory=self.folder)

    @staticmethod
    def api(path, *, binary=False, missing=False):
        """Use GitHub CLI's authenticated redirect handling without exposing the token."""
        result = subprocess.run(["gh", "api", path], capture_output=True)
        if result.returncode:
            if missing and re.search(rb"HTTP (404|410)\b", result.stderr):
                return None
            raise RuntimeError("GitHub artifact API request failed")
        return result.stdout if binary else json.loads(result.stdout)

    def runs(self):
        """List successful CI runs for this exact commit, never PR merge artifacts."""
        repository = self.env["GITHUB_REPOSITORY"]
        if not re.fullmatch(r"[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+", repository):
            raise ValueError("Invalid repository")
        run_id = self.env.get("CI_RUN_ID", "")
        if run_id:
            runs = [self.api(f"repos/{repository}/actions/runs/{self.number(run_id)}")]
        else:
            runs = []
            page = 1
            while True:
                data = self.api(f"repos/{repository}/actions/workflows/android-check.yml/runs"
                                f"?head_sha={self.sha}&status=success&per_page=100&page={page}", missing=True)
                batch = [] if data is None else data["workflow_runs"]
                runs.extend(batch)
                if len(batch) < 100:
                    break
                page += 1
        eligible = []
        for run in runs:
            reason = None
            if run["head_sha"] != self.sha:
                reason = f"source SHA differs: {run['head_sha']} != {self.sha}"
            elif run["conclusion"] != "success":
                reason = "CI did not succeed"
            elif run["path"] != self.WORKFLOW:
                reason = "workflow does not match Android checks"
            elif run["event"] not in ("push", "workflow_dispatch"):
                reason = f"event={run['event']}; PR merge artifacts are not branch-source bundles"
            elif run["head_repository"]["full_name"] != repository:
                reason = "source repository differs"
            if reason is not None:
                print(f"Skip CI run {run['id']}: {reason}.")
            else:
                eligible.append(run)
        if not eligible:
            print(f"No eligible successful push/workflow_dispatch CI run for source {self.sha}. "
                  "Run Android checks on the selected branch before releasing.")
        return sorted(eligible,
                      key=lambda run: (run["run_number"], run["run_attempt"]), reverse=True)

    def unpack(self, archive_bytes, artifact, run):
        """Verify provenance, archive digest, metadata, and bundle bytes before extraction."""
        if artifact.get("digest") != "sha256:" + hashlib.sha256(archive_bytes).hexdigest():
            raise ValueError("GitHub artifact digest mismatch")
        with zipfile.ZipFile(io.BytesIO(archive_bytes)) as archive:
            if sorted(archive.namelist()) != ["app-release.aab", "release.json"]:
                raise ValueError("Unexpected artifact contents")
            metadata = json.loads(archive.read("release.json"))
            bundle = archive.read("app-release.aab")
        version = self.number(metadata["version_code"])
        expected = dict(schema=1, source_sha=self.sha, package=self.PACKAGE,
                        version_name=self.version_name, base_version_code=self.base,
                        flutter_version=self.flutter, ci_run_id=run["id"],
                        ci_run_number=run["run_number"], ci_run_attempt=run["run_attempt"],
                        bundle_sha256=hashlib.sha256(bundle).hexdigest())
        if any(metadata.get(key) != value for key, value in expected.items()):
            raise ValueError("Artifact does not match the requested release")
        if (artifact["name"] != self.name(version) or
                version != self.base + run["run_number"] * 100 + run["run_attempt"] or
                not 0 < version <= self.LIMIT):
            raise ValueError("Artifact version is inconsistent with CI provenance")
        self.unsigned(bundle)
        self.folder.mkdir(parents=True, exist_ok=False)
        (self.folder / "app-release.aab").write_bytes(bundle)
        (self.folder / "release.json").write_text(json.dumps(metadata, indent=2) + "\n")
        return version

    def find(self, minimum, requested=None):
        """Find a deployable CI artifact; only absence/expiry/stale versions cause a rebuild."""
        repository = self.env["GITHUB_REPOSITORY"]
        prefix = f"glarea-aab-{self.version_name}-"
        suffix = f"-{self.sha}"
        print(f"Search CI bundles: source={self.sha}, versionName={self.version_name}, "
              f"minimumVersionCode={minimum}, requestedVersionCode={requested if requested is not None else 'any'}.")
        for run in self.runs():
            print(f"Inspect CI run {run['id']} (event={run['event']}, source={run['head_sha']}).")
            page = 1
            while True:
                data = self.api(f"repos/{repository}/actions/runs/{run['id']}/artifacts?per_page=100&page={page}")
                artifacts = data["artifacts"]
                for artifact in sorted(artifacts, key=lambda item: item["id"], reverse=True):
                    name = artifact["name"]
                    if artifact["expired"]:
                        print(f"Skip artifact {artifact['id']}: expired.")
                        continue
                    if not (name.startswith(prefix) and name.endswith(suffix)):
                        print(f"Skip artifact {artifact['id']}: source SHA or versionName differs ({name}).")
                        continue
                    code = self.number(name[len(prefix):-len(suffix)])
                    if code <= minimum:
                        print(f"Skip artifact {artifact['id']}: versionCode {code} <= used maximum {minimum}.")
                        continue
                    if requested is not None and code != requested:
                        print(f"Skip artifact {artifact['id']}: versionCode {code} != requested {requested}.")
                        continue
                    blob = self.api(f"repos/{repository}/actions/artifacts/{artifact['id']}/zip",
                                    binary=True, missing=True)
                    if blob is None:
                        print(f"Skip artifact {artifact['id']}: archive no longer available.")
                        continue
                    version = self.unpack(blob, artifact, run)
                    print(f"Verified CI artifact {artifact['id']}: versionCode={version}, source={self.sha}.")
                    return version
                if len(artifacts) < 100:
                    break
                page += 1
        print("No deployable CI artifact matched the source and version requirements.")
        return None


if __name__ == "__main__":
    try:
        artifact = BundleArtifact(os.environ)
        if sys.argv[1:] == ["configure"]:
            artifact.configure()
        elif sys.argv[1:] == ["pack"]:
            artifact.pack()
        else:
            raise ValueError("Choose configure or pack")
    except Exception:
        raise SystemExit("Bundle artifact preparation failed. Check source, version configuration, and unsigned build.") from None
