import Foundation

/// Central coordinator: owns the feature managers and wires the global
/// shortcut trigger to the minimize action.
@MainActor
final class AppState: ObservableObject {
    let permissionManager: AccessibilityPermissionManager
    let exclusionListStore: ExclusionListStore
    let launchAtLoginManager: LaunchAtLoginManager

    private let windowMinimizer: WindowMinimizer
    private var shortcutManager: ShortcutManager?

    init(
        permissionManager: AccessibilityPermissionManager = AccessibilityPermissionManager(),
        exclusionListStore: ExclusionListStore = ExclusionListStore(),
        launchAtLoginManager: LaunchAtLoginManager = LaunchAtLoginManager(),
        windowMinimizer: WindowMinimizer = WindowMinimizer(provider: AccessibilityWindowProvider())
    ) {
        self.permissionManager = permissionManager
        self.exclusionListStore = exclusionListStore
        self.launchAtLoginManager = launchAtLoginManager
        self.windowMinimizer = windowMinimizer

        shortcutManager = ShortcutManager { [weak self] in
            self?.minimizeAllWindows()
        }

        permissionManager.startPolling()
    }

    @discardableResult
    func minimizeAllWindows() -> MinimizeResult? {
        guard permissionManager.isTrusted else { return nil }
        return windowMinimizer.minimizeAllWindows(
            excludingBundleIdentifiers: exclusionListStore.excludedBundleIdentifiers
        )
    }
}
