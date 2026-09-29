# Minimize — Planning Phase

## 1. Overview

A free macOS menu bar utility, written in Swift, that minimizes every open
window on the desktop when the user presses a configurable global keyboard
shortcut. No paywall or premium tier.

**Distribution (decided 2026-07-16):** direct download as a notarized DMG,
*not* the Mac App Store — App Sandbox (mandatory for Mac App Store
submission) is incompatible with this app's core function of controlling
other applications' windows (confirmed in step 4 testing; see NFR4). The
app still needs a Developer ID Application certificate and notarization
(both require an Apple Developer Program membership) so Gatekeeper doesn't
block it on other people's Macs — see `DISTRIBUTION.md`.

## 2. High-Level Functions

| # | Function | Description |
|---|----------|-------------|
| F1 | Global shortcut listener | Registers a system-wide keyboard shortcut that triggers window minimization even when the app is not frontmost. |
| F2 | Minimize all windows | Enumerates all open windows across all running apps and minimizes each one individually (genie effect into the Dock), equivalent to clicking each window's yellow minimize button. |
| F3 | Menu bar presence | Runs as a background agent (no Dock icon) with a menu bar item providing access to settings and quit. |
| F4 | Shortcut configuration | Settings UI lets the user record/change the global shortcut. |
| F5 | Exclusion list | Settings UI lets the user pick specific apps that should never be minimized by the shortcut. |
| F6 | Launch at login (optional toggle) | User can enable/disable automatic launch at login from settings. |
| F7 | Permission onboarding | Guides the user to grant Accessibility permission (required to minimize windows owned by other apps) on first launch. |

## 3. Requirements & Acceptance Criteria

### R1 — Global Keyboard Shortcut
**Requirement:** The app shall listen for a user-defined global keyboard shortcut regardless of which app is currently focused.

- **AC1.1:** Pressing the configured shortcut while any other app is frontmost triggers the minimize action.
- **AC1.2:** The default shortcut (before user changes it) is ⌃⌥⌘M.
- **AC1.3:** If the chosen shortcut conflicts with a shortcut already registered by macOS or another app, the settings UI warns the user before saving.

### R2 — Minimize All Windows
**Requirement:** Triggering the shortcut shall minimize every window of every running application, except windows belonging to excluded apps.

- **AC2.1:** All standard, non-excluded windows are minimized to the Dock within 1 second of the shortcut being pressed.
- **AC2.2:** Windows already minimized are left untouched (no un-minimize / toggle behavior).
- **AC2.3:** Windows that do not support minimizing (e.g. some panels/utility windows) are skipped without producing an error.
- **AC2.4:** The app's own menu-bar/settings window (if open) is never minimized by the shortcut.

### R3 — Menu Bar Background Agent
**Requirement:** The app shall run as a menu bar–only background agent with no Dock icon and no regular app window on launch.

- **AC3.1:** On launch, no Dock icon appears and no window opens automatically.
- **AC3.2:** A menu bar icon is always present while the app is running.
- **AC3.3:** Clicking the menu bar icon shows a menu with at least: Settings, Quit.

### R4 — Shortcut Configuration
**Requirement:** The user shall be able to view and change the global shortcut from a settings UI.

- **AC4.1:** Settings UI displays the currently active shortcut.
- **AC4.2:** User can click a "record shortcut" control and press a new key combination to replace it.
- **AC4.3:** The new shortcut takes effect immediately without requiring an app restart.
- **AC4.4:** The chosen shortcut persists across app restarts.

### R5 — Exclusion List
**Requirement:** The user shall be able to designate specific applications that are never minimized by the shortcut.

- **AC5.1:** Settings UI shows a list of currently running/installed apps to choose from, and an add/remove control for the exclusion list.
- **AC5.2:** Apps on the exclusion list are skipped during the minimize action, verified by AC2.4-style check.
- **AC5.3:** The exclusion list persists across app restarts.

### R6 — Launch at Login
**Requirement:** The user shall be able to toggle whether the app automatically launches at login.

- **AC6.1:** Settings UI has a toggle reflecting current launch-at-login state.
- **AC6.2:** Enabling the toggle registers the app to launch at next login; disabling it removes the registration.

### R7 — Accessibility Permission Onboarding
**Requirement:** The app shall detect whether it has Accessibility permission and guide the user to grant it if missing.

- **AC7.1:** On first launch (or whenever permission is missing), the app shows a prompt explaining why Accessibility access is needed and a button that opens System Settings to the correct pane.
- **AC7.2:** The global shortcut does not silently fail when permission is missing — the user is informed via the menu bar UI (e.g. a warning state on the icon).
- **AC7.3:** Once permission is granted, the app detects this without requiring a manual relaunch (or clearly instructs the user to relaunch if that's a platform limitation).

## 4. Non-Functional Requirements

- **NFR1 (Cost):** No paywall, subscription, or in-app purchase of any kind — 100% free.
- **NFR2 (Privacy):** No network access, no analytics/telemetry, no data collection.
- **NFR3 (Performance):** Minimize action completes in under 1 second for typical window counts (≤ 30 windows). **Status (2026-07-16):** an initial implementation hung for ~9.7s in real testing because `AXUIElementCopyAttributeValue` blocks synchronously and several helper/XPC processes never respond to Accessibility queries at all. Fixed via `AXUIElementSetMessagingTimeout` (caps each app's round-trip) plus skipping `.prohibited`-activation-policy apps (no UI, so never worth querying) before making any AX call. Measured real-device latency after the fix: ~0.6–1.4s depending on how many non-UI helper processes are running — a ~85%+ reduction from the original hang, though not a hard guarantee of sub-1s on every machine. Further tightening the timeout has diminishing returns and risks skipping genuinely slow-but-real apps.
- **NFR4 (Distribution):** Decided (2026-07-16): direct download as a notarized, Developer-ID-signed DMG — not the Mac App Store, since App Sandbox (mandatory for MAS) is incompatible with this app's core function (confirmed in step 4 testing, see below). Requires an Apple Developer Program membership for the Developer ID Application certificate and notarization; see `DISTRIBUTION.md`.
- **NFR5 (Platform):** Minimum supported macOS version is macOS Tahoe 26.5.

## 5. Open Questions / Risks to Revisit

- **CONFIRMED BLOCKER (2026-07-16):** With App Sandbox enabled, every cross-process Accessibility call (`AXUIElementCopyAttributeValue`/`AXUIElementSetAttributeValue` against other apps' windows) fails with `kAXErrorAPIDisabled`, even with Accessibility permission granted in System Settings. Verified empirically (real device test: sandbox on → 0 windows minimized across all apps; sandbox off, same permission grant → works correctly). This matches statements from Apple DTS engineers on the Apple Developer Forums: there is no entitlement that lifts this restriction for third-party apps, and it applies regardless of code signing method. Window managers like Magnet/Rectangle either ship outside the Mac App Store or run unsandboxed.
  - **Resolved (2026-07-16):** distributing directly (notarized DMG, outside the Mac App Store) rather than attempting an unsandboxed Mac App Store submission (which App Review would very likely reject). See `DISTRIBUTION.md` for the prepared release process.
  - The project's entitlements file ships with `com.apple.security.app-sandbox = false`, consistent with this direct-distribution decision.
