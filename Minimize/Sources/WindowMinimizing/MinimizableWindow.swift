import Foundation

/// A single window as seen by the minimizer, independent of how it was discovered.
/// `token` is an opaque handle the originating `AccessibilityWindowProviding`
/// implementation uses to map back to the underlying platform object.
struct MinimizableWindow {
    let token: AnyHashable
    let ownerBundleIdentifier: String?
    let ownerName: String
    let isMinimized: Bool
    let canMinimize: Bool
}
