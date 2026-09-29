import SwiftUI

@main
struct MinimizeApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        MenuBarExtra {
            MenuBarMenuView()
                .environmentObject(appState)
        } label: {
            MenuBarIcon()
                .environmentObject(appState)
        }
        .menuBarExtraStyle(.menu)

        Settings {
            SettingsView()
                .environmentObject(appState)
        }
    }
}
