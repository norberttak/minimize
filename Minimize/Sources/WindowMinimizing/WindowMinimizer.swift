import Foundation

struct MinimizeResult: Equatable {
    var minimizedCount = 0
    var skippedExcludedCount = 0
    var skippedAlreadyMinimizedCount = 0
    var skippedNonMinimizableCount = 0
}

/// Core logic for requirement R2 (minimize all windows). Owns only the
/// filtering rules (AC2.1-AC2.4); actual window discovery/minimizing is
/// delegated to an `AccessibilityWindowProviding` implementation.
final class WindowMinimizer {
    private let provider: AccessibilityWindowProviding

    init(provider: AccessibilityWindowProviding) {
        self.provider = provider
    }

    @discardableResult
    func minimizeAllWindows(excludingBundleIdentifiers excluded: Set<String>) -> MinimizeResult {
        var result = MinimizeResult()

        for window in provider.fetchWindows() {
            if let bundleId = window.ownerBundleIdentifier, excluded.contains(bundleId) {
                result.skippedExcludedCount += 1
                continue
            }
            if window.isMinimized {
                result.skippedAlreadyMinimizedCount += 1
                continue
            }
            guard window.canMinimize else {
                result.skippedNonMinimizableCount += 1
                continue
            }
            provider.minimize(window)
            result.minimizedCount += 1
        }

        return result
    }
}
