import Foundation
import ApplicationServices

/// Abstracts the raw TCC/Accessibility trust check so it can be faked in tests.
protocol AccessibilityPermissionChecking {
    func isTrusted(promptIfNeeded: Bool) -> Bool
}

struct SystemAccessibilityChecker: AccessibilityPermissionChecking {
    func isTrusted(promptIfNeeded: Bool) -> Bool {
        // Hardcoded rather than reading the `kAXTrustedCheckOptionPrompt`
        // global (an `Unmanaged<CFString>!`) to avoid a Swift 6 strict
        // concurrency error over shared mutable state; the key's string
        // value is a stable, documented part of the Accessibility API.
        let options: NSDictionary = ["AXTrustedCheckOptionPrompt": promptIfNeeded]
        return AXIsProcessTrustedWithOptions(options)
    }
}
