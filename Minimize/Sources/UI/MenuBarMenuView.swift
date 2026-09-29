import AppKit
import SwiftUI

/// Menu shown when the menu bar icon is clicked (AC3.3).
struct MenuBarMenuView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        if !appState.permissionManager.isTrusted {
            Button("Grant Accessibility Permission…") {
                appState.permissionManager.requestPermission()
            }
            Divider()
        }

        SettingsLink {
            Text("Settings…")
        }
        .keyboardShortcut(",", modifiers: .command)

        Divider()

        Button("Quit Minimize") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q", modifiers: .command)
    }
}
