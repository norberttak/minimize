import AppKit
import Combine

/// Tracks Accessibility (TCC) permission state for requirement R7.
/// Polls periodically so the app notices a grant made in System Settings
/// without requiring a relaunch (AC7.3).
@MainActor
final class AccessibilityPermissionManager: ObservableObject {
    @Published private(set) var isTrusted: Bool

    private let checker: AccessibilityPermissionChecking
    // Timer invalidation is thread-safe; marked unsafe so `deinit` (nonisolated)
    // can tear it down without hopping to the main actor.
    nonisolated(unsafe) private var pollTimer: Timer?

    init(checker: AccessibilityPermissionChecking = SystemAccessibilityChecker()) {
        self.checker = checker
        self.isTrusted = checker.isTrusted(promptIfNeeded: false)
    }

    func refresh() {
        isTrusted = checker.isTrusted(promptIfNeeded: false)
    }

    /// Triggers the system "Minimize would like to control your computer"
    /// prompt if permission hasn't been decided yet (AC7.1).
    func requestPermission() {
        _ = checker.isTrusted(promptIfNeeded: true)
        refresh()
    }

    func startPolling(interval: TimeInterval = 2) {
        stopPolling()
        pollTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.refresh() }
        }
    }

    func stopPolling() {
        pollTimer?.invalidate()
        pollTimer = nil
    }

    /// Opens System Settings directly to the Accessibility pane (AC7.1).
    func openSystemSettings() {
        guard let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") else { return }
        NSWorkspace.shared.open(url)
    }

    deinit {
        pollTimer?.invalidate()
    }
}
