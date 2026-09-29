import KeyboardShortcuts
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appState: AppState
    @State private var runningApps: [RunningAppInfo] = []
    @State private var showsShortcutConflictWarning = false

    var body: some View {
        TabView {
            generalTab
                .tabItem { Text("General") }
            exclusionsTab
                .tabItem { Text("Exclusions") }
        }
        .frame(width: 440, height: 380)
        .onAppear(perform: refreshRunningApps)
    }

    private var generalTab: some View {
        Form {
            Section("Shortcut") {
                KeyboardShortcuts.Recorder("Minimize All Windows:", name: .minimizeAllWindows) { shortcut in
                    showsShortcutConflictWarning = ReservedShortcutChecker.isReserved(shortcut)
                }
                if showsShortcutConflictWarning {
                    Label("This combination may conflict with a system shortcut.", systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.orange)
                        .font(.footnote)
                }
            }

            Section("Startup") {
                Toggle("Launch Minimize at login", isOn: Binding(
                    get: { appState.launchAtLoginManager.isEnabled },
                    set: { appState.launchAtLoginManager.setEnabled($0) }
                ))
            }

            Section("Accessibility") {
                if appState.permissionManager.isTrusted {
                    Label("Accessibility access granted", systemImage: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                } else {
                    Label("Accessibility access is required to minimize other apps' windows.", systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                    Button("Open System Settings…") {
                        appState.permissionManager.openSystemSettings()
                    }
                }
            }
        }
        .padding()
    }

    private var exclusionsTab: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Apps checked below are never minimized by the shortcut.")
                .foregroundStyle(.secondary)
                .font(.footnote)

            List(runningApps) { app in
                Toggle(isOn: Binding(
                    get: { appState.exclusionListStore.isExcluded(app.bundleIdentifier) },
                    set: { isExcluded in
                        if isExcluded {
                            appState.exclusionListStore.exclude(app.bundleIdentifier)
                        } else {
                            appState.exclusionListStore.include(app.bundleIdentifier)
                        }
                    }
                )) {
                    Text(app.name)
                }
            }
        }
        .padding()
    }

    private func refreshRunningApps() {
        runningApps = RunningAppInfo.currentRunningApps()
    }
}
