import AppKit

/// Lightweight, display-ready description of a running app, used to
/// populate the exclusion list picker in Settings.
struct RunningAppInfo: Identifiable, Hashable {
    let id: String
    let bundleIdentifier: String
    let name: String

    static func currentRunningApps() -> [RunningAppInfo] {
        let ownBundleIdentifier = Bundle.main.bundleIdentifier

        return NSWorkspace.shared.runningApplications
            .filter { $0.activationPolicy == .regular }
            .compactMap { app -> RunningAppInfo? in
                guard let bundleIdentifier = app.bundleIdentifier,
                      bundleIdentifier != ownBundleIdentifier else { return nil }
                let name = app.localizedName ?? bundleIdentifier
                return RunningAppInfo(id: bundleIdentifier, bundleIdentifier: bundleIdentifier, name: name)
            }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
}
