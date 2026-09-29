# Minimize — Test Plan (Test Case Descriptions)

Test cases are grouped by requirement (see `PLANNING.md`). This phase defines
*what* to test, not *how* — implementations follow in the implementation
phase. Each case references the acceptance criteria (AC) it verifies.

## R1 — Global Keyboard Shortcut

| ID | Title | Verifies | Description |
|----|-------|----------|-------------|
| TC1.1 | Shortcut triggers while another app is frontmost | AC1.1 | With a third-party app (e.g. Safari) focused, press the configured shortcut and confirm the minimize action fires. |
| TC1.2 | Default shortcut is ⌃⌥⌘M on first launch | AC1.2 | Fresh install/first launch, no prior settings; verify the settings UI shows ⌃⌥⌘M as active and that pressing it triggers minimize. |
| TC1.3 | Shortcut fires from any Space/desktop | AC1.1 | Switch to a different Space (Mission Control) and confirm the shortcut still triggers minimize for windows on that Space. |
| TC1.4 | Conflicting shortcut shows a warning | AC1.3 | Attempt to set the shortcut to a combination already used by macOS (e.g. ⌘Space) and confirm a warning is shown before saving. |
| TC1.5 | Non-conflicting shortcut saves without warning | AC1.3 | Set an unused combination and confirm no warning appears and the value saves. |

## R2 — Minimize All Windows

| ID | Title | Verifies | Description |
|----|-------|----------|-------------|
| TC2.1 | All windows minimize on shortcut press | AC2.1 | Open windows from several different apps, press the shortcut, confirm every window is minimized to the Dock. |
| TC2.2 | Minimize completes within 1 second | AC2.1 | With a typical window count (~10), time from key press to all windows minimized; confirm under 1 second. |
| TC2.3 | Already-minimized windows are left alone | AC2.2 | Pre-minimize one window, open others, trigger shortcut, confirm no un-minimize/toggle occurs on the already-minimized window. |
| TC2.4 | Non-minimizable windows are skipped without error | AC2.3 | Open a window/panel that does not support minimizing (e.g. a small utility dialog), trigger shortcut, confirm no crash/error and other windows still minimize. |
| TC2.5 | App's own settings window is never minimized | AC2.4 | Open the app's Settings window, trigger the shortcut, confirm the Settings window remains open/visible while other windows minimize. |
| TC2.6 | Large window count (stress) | AC2.1, NFR3 | Open ~30 windows across multiple apps, trigger shortcut, confirm all minimize and timing stays within the performance target. |
| TC2.7 | No windows open | AC2.1 | With no other windows open, trigger the shortcut and confirm no crash or unexpected behavior. |

## R3 — Menu Bar Background Agent

| ID | Title | Verifies | Description |
|----|-------|----------|-------------|
| TC3.1 | No Dock icon on launch | AC3.1 | Launch the app and confirm no icon appears in the Dock. |
| TC3.2 | No window opens automatically on launch | AC3.1 | Launch the app and confirm no window is shown without user interaction. |
| TC3.3 | Menu bar icon always present | AC3.2 | Confirm the menu bar icon is visible immediately after launch and remains present during normal use. |
| TC3.4 | Menu bar menu contains Settings and Quit | AC3.3 | Click the menu bar icon and confirm a menu appears with at least "Settings" and "Quit" items. |
| TC3.5 | Quit terminates the app | AC3.3 | Select "Quit" from the menu and confirm the app process ends and the menu bar icon disappears. |

## R4 — Shortcut Configuration

| ID | Title | Verifies | Description |
|----|-------|----------|-------------|
| TC4.1 | Settings displays current shortcut | AC4.1 | Open settings and confirm the currently active shortcut is shown accurately. |
| TC4.2 | Recording a new shortcut replaces the old one | AC4.2 | Click "record shortcut," press a new key combination, confirm the UI updates to reflect the new combination. |
| TC4.3 | New shortcut works immediately without restart | AC4.3 | After changing the shortcut, trigger it without restarting the app and confirm minimize fires; confirm the old shortcut no longer triggers it. |
| TC4.4 | Shortcut persists across restart | AC4.4 | Change the shortcut, quit and relaunch the app, confirm the custom shortcut is still active. |

## R5 — Exclusion List

| ID | Title | Verifies | Description |
|----|-------|----------|-------------|
| TC5.1 | Settings shows app list with add/remove controls | AC5.1 | Open settings, confirm a list of apps is shown along with controls to add/remove entries from the exclusion list. |
| TC5.2 | Excluded app's windows are not minimized | AC5.2 | Add an app to the exclusion list, open one of its windows plus windows from a non-excluded app, trigger shortcut, confirm only the non-excluded app's windows minimize. |
| TC5.3 | Removing an app from the exclusion list restores default behavior | AC5.2 | Remove a previously excluded app, trigger shortcut, confirm its windows now minimize normally. |
| TC5.4 | Exclusion list persists across restart | AC5.3 | Add an app to the exclusion list, quit and relaunch, confirm the exclusion list still contains it and behavior is unchanged. |

## R6 — Launch at Login

| ID | Title | Verifies | Description |
|----|-------|----------|-------------|
| TC6.1 | Toggle reflects current state | AC6.1 | Open settings and confirm the launch-at-login toggle accurately reflects whether the app is currently registered to launch at login. |
| TC6.2 | Enabling toggle registers launch at login | AC6.2 | Enable the toggle, restart the Mac (or use system tooling to verify registration), confirm the app launches automatically at next login. |
| TC6.3 | Disabling toggle removes launch at login | AC6.2 | Disable the toggle, confirm the app is no longer registered to launch at login. |

## R7 — Accessibility Permission Onboarding

| ID | Title | Verifies | Description |
|----|-------|----------|-------------|
| TC7.1 | Missing permission prompts onboarding on first launch | AC7.1 | On a fresh system/user without prior grant, launch the app and confirm a prompt explains the need for Accessibility access with a button to open System Settings. |
| TC7.2 | Prompt opens the correct System Settings pane | AC7.1 | Click the prompt's action button and confirm System Settings opens directly to the Accessibility/Privacy pane. |
| TC7.3 | Shortcut failure is visible when permission is missing | AC7.2 | Without granting permission, trigger the shortcut and confirm the menu bar icon shows a warning state rather than silently doing nothing. |
| TC7.4 | App detects permission grant | AC7.3 | Grant Accessibility permission while the app is running (or after a relaunch, if required), confirm the app recognizes the change and the warning state clears. |
| TC7.5 | Shortcut works normally once permission is granted | AC7.2, AC7.3 | With permission granted, trigger the shortcut and confirm windows minimize normally with no warning shown. |

## Non-Functional Test Cases

| ID | Title | Verifies | Description |
|----|-------|----------|-------------|
| TC-NFR1.1 | No purchase/paywall UI present | NFR1 | Inspect all app screens/menus and confirm no purchase prompts, paywalls, or locked features exist anywhere. |
| TC-NFR2.1 | No network activity | NFR2 | Monitor network traffic during typical app usage (launch, minimize, settings changes) and confirm zero outbound connections. |
| TC-NFR3.1 | Performance under typical load | NFR3 | Covered by TC2.2/TC2.6 — minimize completes within 1 second for ≤30 windows. |
| TC-NFR4.1 | App Store sandbox compliance | NFR4 | Validate the app runs correctly under the App Sandbox with only the entitlements it declares (to be re-verified once implementation exists). |
| TC-NFR5.1 | Runs on minimum supported OS version | NFR5 | Verify app launches and all core functions (TC1–TC7) work correctly on macOS Tahoe 26.5. |
