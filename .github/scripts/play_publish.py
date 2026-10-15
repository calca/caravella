"""Promote an uploaded bundle to a Play track and sync store texts.

Uses the Google Play Developer API (androidpublisher v3) with the same
service account as the "Android CI - Store" upload step. In one edit it:
  * sets the target track to the given version code with release notes
    parsed from store/changelog/release-notes-<version>.xml;
  * updates the short and full description of every existing store listing
    from store/metadata/listing_<lang>.md (the title is left untouched: the
    repo titles exceed Play's 30-char limit in some languages);
  * replaces each listing's feature graphic with
    store/assets/feature-graphic/<lang>.png (1024x500) and its phone
    screenshots with store/screenshots/<lang>/*.jpg|png (sorted by name),
    when present.

Only languages that already have a Play store listing are touched, since
Play rejects release notes for languages without one.

Env: PLAY_SERVICE_ACCOUNT_JSON (service account key, JSON text).
"""

import argparse
import json
import os
import re
import sys

from google.oauth2 import service_account
from googleapiclient.discovery import build
from googleapiclient.http import MediaFileUpload

PACKAGE = "io.caravella.egm"
SCOPES = ["https://www.googleapis.com/auth/androidpublisher"]
MAX_NOTES = 500
MAX_SHORT_DESCRIPTION = 80
MAX_FULL_DESCRIPTION = 4000


def parse_release_notes(path):
    with open(path, encoding="utf-8") as f:
        text = f.read()
    return {
        lang: body.strip()
        for lang, body in re.findall(r"<([A-Za-z0-9-]+)>\n?(.*?)</\1>", text, re.S)
    }


def parse_listing(path):
    # Files have three "## " sections: name, short description, full description.
    with open(path, encoding="utf-8") as f:
        sections = re.split(r"^## .*$", f.read(), flags=re.M)
    if len(sections) != 4:
        sys.exit(f"{path}: expected 3 '## ' sections, found {len(sections) - 1}")
    short, full = sections[2].strip(), sections[3].strip()
    if not short or len(short) > MAX_SHORT_DESCRIPTION:
        sys.exit(f"{path}: short description is {len(short)} chars (max {MAX_SHORT_DESCRIPTION})")
    if not full or len(full) > MAX_FULL_DESCRIPTION:
        sys.exit(f"{path}: full description is {len(full)} chars (max {MAX_FULL_DESCRIPTION})")
    return short, full


def listing_file_for(language):
    return os.path.join("store", "metadata", f"listing_{language.split('-')[0]}.md")


def feature_graphic_for(language):
    return os.path.join("store", "assets", "feature-graphic", f"{language.split('-')[0]}.png")


def screenshots_for(language):
    folder = os.path.join("store", "screenshots", language.split("-")[0])
    if not os.path.isdir(folder):
        return []
    return [os.path.join(folder, f) for f in sorted(os.listdir(folder))
            if f.lower().endswith((".jpg", ".jpeg", ".png"))]


def replace_images(edits, edit_id, language, image_type, paths):
    edits.images().deleteall(packageName=PACKAGE, editId=edit_id,
                             language=language, imageType=image_type).execute()
    for path in paths:
        mime = "image/png" if path.lower().endswith(".png") else "image/jpeg"
        edits.images().upload(packageName=PACKAGE, editId=edit_id, language=language,
                              imageType=image_type,
                              media_body=MediaFileUpload(path, mimetype=mime)).execute()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--version-name", required=True)
    parser.add_argument("--version-code", required=True, type=int)
    parser.add_argument("--track", default="production")
    parser.add_argument("--rollout", type=float, default=1.0,
                        help="User fraction (0-1]; below 1 creates a staged rollout")
    parser.add_argument("--skip-listing", action="store_true")
    parser.add_argument("--skip-release", action="store_true",
                        help="Leave the track untouched (listing-only update)")
    parser.add_argument("--dry-run", action="store_true",
                        help="Validate the edit without committing it")
    args = parser.parse_args()

    credentials = service_account.Credentials.from_service_account_info(
        json.loads(os.environ["PLAY_SERVICE_ACCOUNT_JSON"]), scopes=SCOPES)
    edits = build("androidpublisher", "v3", credentials=credentials,
                  cache_discovery=False).edits()

    edit_id = edits.insert(packageName=PACKAGE, body={}).execute()["id"]
    listings = edits.listings().list(packageName=PACKAGE, editId=edit_id).execute()
    languages = [l["language"] for l in listings.get("listings", [])]
    print(f"Store listing languages: {', '.join(languages)}")

    if args.skip_release:
        print(f"Track {args.track}: left untouched")
    else:
        notes_path = os.path.join("store", "changelog", f"release-notes-{args.version_name}.xml")
        all_notes = parse_release_notes(notes_path)
        release_notes = []
        for language in languages:
            note = all_notes.get(language) or all_notes.get(language.split("-")[0])
            if not note:
                print(f"  no release notes for {language}, skipping")
                continue
            if len(note) > MAX_NOTES:
                sys.exit(f"Release notes for {language} are {len(note)} chars (max {MAX_NOTES})")
            release_notes.append({"language": language, "text": note})
        print(f"Release notes: {', '.join(n['language'] for n in release_notes)}")

        release = {
            "name": args.version_name,
            "versionCodes": [str(args.version_code)],
            "releaseNotes": release_notes,
        }
        if args.rollout < 1.0:
            release.update(status="inProgress", userFraction=args.rollout)
        else:
            release["status"] = "completed"
        edits.tracks().update(packageName=PACKAGE, editId=edit_id, track=args.track,
                              body={"track": args.track, "releases": [release]}).execute()
        print(f"Track {args.track}: {args.version_name} ({args.version_code}), status {release['status']}")

    if not args.skip_listing:
        for listing in listings.get("listings", []):
            path = listing_file_for(listing["language"])
            if not os.path.exists(path):
                print(f"  no {path}, keeping {listing['language']} listing as is")
                continue
            short, full = parse_listing(path)
            edits.listings().patch(packageName=PACKAGE, editId=edit_id,
                                   language=listing["language"],
                                   body={"shortDescription": short,
                                         "fullDescription": full}).execute()
            print(f"  listing {listing['language']}: descriptions from {path}")

            graphic = feature_graphic_for(listing["language"])
            if os.path.exists(graphic):
                replace_images(edits, edit_id, listing["language"], "featureGraphic", [graphic])
                print(f"  listing {listing['language']}: feature graphic from {graphic}")

            shots = screenshots_for(listing["language"])
            if shots:
                if len(shots) > 8:
                    sys.exit(f"{len(shots)} screenshots for {listing['language']} (Play max 8)")
                replace_images(edits, edit_id, listing["language"], "phoneScreenshots", shots)
                print(f"  listing {listing['language']}: {len(shots)} phone screenshots "
                      f"from {os.path.dirname(shots[0])}")

    if args.dry_run:
        edits.validate(packageName=PACKAGE, editId=edit_id).execute()
        edits.delete(packageName=PACKAGE, editId=edit_id).execute()
        print("Dry run: edit validated and discarded")
    else:
        edits.commit(packageName=PACKAGE, editId=edit_id).execute()
        print("Edit committed")


if __name__ == "__main__":
    main()
