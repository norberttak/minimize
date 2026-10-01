#!/bin/bash
# Builds, signs, notarizes, and packages Minimize as a distributable DMG.
#
# Requires (see DISTRIBUTION.md for one-time setup):
#   - DEVELOPER_ID_APPLICATION: exact signing identity, e.g.
#     "Developer ID Application: Jane Doe (ABCDE12345)"
#   - DEVELOPMENT_TEAM: your Apple Developer Team ID, e.g. "ABCDE12345"
#   - NOTARY_PROFILE: name of a keychain profile created with
#     `xcrun notarytool store-credentials`
#

DEVELOPER_ID_APPLICATION="Developer ID Application"
DEVELOPMENT_TEAM="JSA8AVL9RJ"
NOTARY_PROFILE="Minimize-notary"

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

: "${DEVELOPER_ID_APPLICATION:?Set DEVELOPER_ID_APPLICATION to your Developer ID Application signing identity}"
: "${DEVELOPMENT_TEAM:?Set DEVELOPMENT_TEAM to your Apple Developer Team ID}"
: "${NOTARY_PROFILE:?Set NOTARY_PROFILE to a notarytool keychain profile name (see DISTRIBUTION.md)}"

APP_NAME="Minimize"
DIST_DIR="$ROOT_DIR/dist"
ARCHIVE_PATH="$DIST_DIR/$APP_NAME.xcarchive"
EXPORT_DIR="$DIST_DIR/export"
APP_PATH="$EXPORT_DIR/$APP_NAME.app"
ZIP_PATH="$DIST_DIR/$APP_NAME.zip"
VERSION=$(grep -m1 'MARKETING_VERSION' project.yml | sed 's/.*: *"\(.*\)"/\1/')
DMG_PATH="$DIST_DIR/$APP_NAME-$VERSION.dmg"

rm -rf "$DIST_DIR"
mkdir -p "$DIST_DIR"

echo "==> Generating Xcode project"
xcodegen generate

echo "==> Archiving (Release, Developer ID signed)"
xcodebuild archive \
  -project "$APP_NAME.xcodeproj" \
  -scheme "$APP_NAME" \
  -configuration Release \
  -archivePath "$ARCHIVE_PATH" \
  CODE_SIGN_STYLE=Manual \
  CODE_SIGN_IDENTITY="$DEVELOPER_ID_APPLICATION" \
  DEVELOPMENT_TEAM="$DEVELOPMENT_TEAM" \
  ENABLE_HARDENED_RUNTIME=YES

echo "==> Exporting signed .app from archive"
mkdir -p "$EXPORT_DIR"
cp -R "$ARCHIVE_PATH/Products/Applications/$APP_NAME.app" "$APP_PATH"

echo "==> Verifying code signature"
codesign --verify --deep --strict --verbose=2 "$APP_PATH"

echo "==> Zipping for notarization"
ditto -c -k --keepParent "$APP_PATH" "$ZIP_PATH"

echo "==> Submitting for notarization (this can take a few minutes)"
xcrun notarytool submit "$ZIP_PATH" --keychain-profile "$NOTARY_PROFILE" --wait

echo "==> Stapling notarization ticket"
xcrun stapler staple "$APP_PATH"

echo "==> Building DMG"
STAGING_DIR="$DIST_DIR/dmg-staging"
mkdir -p "$STAGING_DIR"
cp -R "$APP_PATH" "$STAGING_DIR/"
ln -s /Applications "$STAGING_DIR/Applications"
hdiutil create -volname "$APP_NAME" -srcfolder "$STAGING_DIR" -ov -format UDZO "$DMG_PATH"

echo "==> Signing DMG"
codesign --sign "$DEVELOPER_ID_APPLICATION" --timestamp "$DMG_PATH"
codesign --verify --strict --verbose=2 "$DMG_PATH"

echo "==> Submitting DMG for notarization (this can take a few minutes)"
xcrun notarytool submit "$DMG_PATH" --keychain-profile "$NOTARY_PROFILE" --wait

echo "==> Stapling notarization ticket to DMG"
xcrun stapler staple "$DMG_PATH"

echo "==> Gatekeeper check"
spctl --assess --type open --context context:primary-signature --verbose=2 "$DMG_PATH"

echo "==> Done: $DMG_PATH"
