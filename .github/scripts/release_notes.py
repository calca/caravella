#!/usr/bin/env python3
"""Print GitHub release notes for a version, taken from CHANGELOG.md.

usage: release_notes.py <version|Unreleased> --kind prerelease|store
                        [--tag TAG] [--previous-tag TAG] [--commit SHA]

Prints the body of the CHANGELOG section `## [<version>]` (or
`## [Unreleased]`), followed by a short header/footer for the release kind.
Exits with status 1 when the section is missing or empty, so a store release
can't go out without notes.
"""
import argparse
import re
import sys
from pathlib import Path

CHANGELOG = Path(__file__).resolve().parents[2] / "CHANGELOG.md"
REPO = "https://github.com/calca/caravella"


def section(text: str, version: str) -> str:
    pattern = re.compile(
        r"^## \[" + re.escape(version) + r"\][^\n]*\n(.*?)(?=^## \[|^\[[^\]]+\]: |\Z)",
        re.M | re.S,
    )
    m = pattern.search(text)
    return m.group(1).strip() if m else ""


def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("version")
    p.add_argument("--kind", choices=["prerelease", "store"], required=True)
    p.add_argument("--tag")
    p.add_argument("--previous-tag")
    p.add_argument("--commit")
    a = p.parse_args()

    body = section(CHANGELOG.read_text(encoding="utf-8"), a.version)
    if not body:
        print(f"CHANGELOG.md has no entries under [{a.version}]", file=sys.stderr)
        return 1

    out = []
    if a.kind == "prerelease":
        out.append(
            "> **Test build, not published on Google Play.** Staging flavor: it "
            "installs next to the Play Store app (\"Caravella - Staging\", its own "
            "data) and has the debug log screen enabled.\n"
        )
    out.append(body)
    out.append("\n---")
    if a.kind == "store":
        out.append(
            "The same version is on [Google Play]"
            "(https://play.google.com/store/apps/details?id=io.caravella.egm). "
            "The attached APK is for installing without Play: it is signed with "
            "a different key than the Play Store app, so it can't update an "
            "installation that came from Play (uninstall that first; data is "
            "not carried over)."
        )
    if a.commit:
        out.append(f"\nBuilt from {a.commit}.")
    if a.tag and a.previous_tag:
        out.append(f"\n**Full diff**: {REPO}/compare/{a.previous_tag}...{a.tag}")
    print("\n".join(out))
    return 0


if __name__ == "__main__":
    sys.exit(main())
