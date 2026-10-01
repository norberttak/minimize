import AppKit
import SwiftUI

/// Menu shown when the menu bar icon is clicked (AC3.3).
struct MenuBarMenuView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.openSettings) private var openSettings

    var body: some View {
        if !appState.permissionManager.isTrusted {
            Button("Grant Accessibility Permission…") {
                appState.permissionManager.requestPermission()
            }
            Divider()
        }

        // As a menu bar-only app (LSUIElement) Minimize is never the active
        // app, so a plain SettingsLink opens the window behind other apps.
        // Activating first brings the Settings window to the front.
        Button("Settings…") {
            NSApp.activate()
            openSettings()
        }
        .keyboardShortcut(",", modifiers: .command)

        Divider()

        Button("Quit Minimize") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q", modifiers: .command)
    }
}
