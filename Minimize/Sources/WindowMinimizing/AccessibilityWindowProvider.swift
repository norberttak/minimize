import AppKit
import ApplicationServices

/// Real `AccessibilityWindowProviding` implementation backed by the
/// Accessibility API. Enumerates windows of every running app except this
/// one, so this app's own Settings window is never a candidate (AC2.4).
final class AccessibilityWindowProvider: AccessibilityWindowProviding {
    private var tokenMap: [UUID: AXUIElement] = [:]

    func fetchWindows() -> [MinimizableWindow] {
        tokenMap.removeAll()

        let ownBundleIdentifier = Bundle.main.bundleIdentifier
        var results: [MinimizableWindow] = []

        for app in NSWorkspace.shared.runningApplications {
            // `.prohibited` apps have no UI presence at all (XPC helpers,
            // WebKit content processes, background services); they never
            // own windows but plenty of them don't respond to Accessibility
            // queries either, so querying them just burns the messaging
            // timeout on every minimize. Skipping them up front is what
            // keeps AC2.1/NFR3's "under 1 second" true on a typical desktop.
            guard app.activationPolicy != .prohibited,
                  let bundleIdentifier = app.bundleIdentifier,
                  bundleIdentifier != ownBundleIdentifier else { continue }

            let axApp = AXUIElementCreateApplication(app.processIdentifier)
            // Bounds how long a single unresponsive app can block this
            // synchronous call (AC2.1/NFR3: minimize must complete quickly
            // even if some other app is slow to answer Accessibility
            // requests).
            AXUIElementSetMessagingTimeout(axApp, 0.05)

            var windowsValue: CFTypeRef?
            let error = AXUIElementCopyAttributeValue(axApp, kAXWindowsAttribute as CFString, &windowsValue)
            guard error == .success, let axWindows = windowsValue as? [AXUIElement] else { continue }

            let ownerName = app.localizedName ?? bundleIdentifier

            for axWindow in axWindows {
                let token = UUID()
                tokenMap[token] = axWindow

                results.append(MinimizableWindow(
                    token: token,
                    ownerBundleIdentifier: bundleIdentifier,
                    ownerName: ownerName,
                    isMinimized: Self.isMinimized(axWindow),
                    canMinimize: Self.canMinimize(axWindow)
                ))
            }
        }

        return results
    }

    func minimize(_ window: MinimizableWindow) {
        guard let uuid = window.token.base as? UUID, let axWindow = tokenMap[uuid] else { return }
        AXUIElementSetAttributeValue(axWindow, kAXMinimizedAttribute as CFString, kCFBooleanTrue)
    }

    private static func isMinimized(_ axWindow: AXUIElement) -> Bool {
        var value: CFTypeRef?
        guard AXUIElementCopyAttributeValue(axWindow, kAXMinimizedAttribute as CFString, &value) == .success else {
            return false
        }
        return (value as? Bool) ?? false
    }

    private static func canMinimize(_ axWindow: AXUIElement) -> Bool {
        var settable: DarwinBoolean = false
        let result = AXUIElementIsAttributeSettable(axWindow, kAXMinimizedAttribute as CFString, &settable)
        return result == .success && settable.boolValue
    }
}
