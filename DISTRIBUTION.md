# Distribution

Minimize ships as a direct-download, notarized DMG — **not** through the Mac
App Store. App Sandbox is mandatory for Mac App Store submission, and it
blocks the Accessibility calls this app needs to control other applications'
windows (confirmed in real-device testing; see `PLANNING.md` NFR4). Window
managers like Magnet and Rectangle hit the same wall; Rectangle ships the
same way this app does.

None of the steps below can run yet — they require an Apple Developer
Program membership, which the project doesn't have. This document exists so
release is a single script run once that membership is in place.

## One-time setup (once you have a Developer account)

1. **Enroll** in the [Apple Developer Program](https://developer.apple.com/programs/) ($99/year).
2. **Create a Developer ID Application certificate**: Xcode → Settings →
   Accounts → select your Apple ID → Manage Certificates → + → "Developer ID
   Application". Note the exact identity string it creates, e.g.
   `Developer ID Application: Jane Doe (ABCDE12345)`.
3. **Find your Team ID**: developer.apple.com → Account → Membership
   details, or `xcrun altool --list-providers -u you@example.com` — it's the
   parenthesized code in the certificate name above (`ABCDE12345`).
4. **Create a notarytool keychain profile** (stores your credentials once,
   locally, so the release script doesn't need them inline):
   ```
   xcrun notarytool store-credentials "Minimize-notary" \
     --apple-id "you@example.com" \
     --team-id "ABCDE12345" \
     --password "an-app-specific-password"
   ```
   The password is an [app-specific password](https://support.apple.com/en-us/102654),
   not your Apple ID password.

## Building a release

```
DEVELOPER_ID_APPLICATION="Developer ID Application: Jane Doe (ABCDE12345)" \
DEVELOPMENT_TEAM="ABCDE12345" \
NOTARY_PROFILE="Minimize-notary" \
./Scripts/release.sh
```

This archives a Release build signed with your Developer ID, submits it to
Apple for notarization and waits for approval, staples the notarization
ticket to the app, and packages it into `dist/Minimize-<version>.dmg`
(drag-to-Applications layout). The version number comes from
`MARKETING_VERSION` in `project.yml`.

## Verifying before publishing

```
spctl --assess --type execute -v dist/export/Minimize.app
```

Should report `accepted` and `source=Notarized Developer ID`. If it doesn't,
don't publish — Gatekeeper will block the app for users.

## What's already handled in the app itself

- The app requests Accessibility permission (F7) rather than assuming it —
  first-run users get a real onboarding prompt, not a silent failure.
- Launch-at-login (F6) uses `SMAppService`, which works for a plain signed
  `.app` outside any installer — no separate login-item helper needed.
- No auto-update mechanism exists yet. Until one is added, updating the app
  means downloading and reinstalling a new DMG. If update frequency ends up
  mattering, something like [Sparkle](https://sparkle-project.org/) is the
  standard choice for this distribution model — not set up yet since it's a
  new dependency and out of scope until there's an actual release to update.
