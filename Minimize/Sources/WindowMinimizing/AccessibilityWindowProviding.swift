import Foundation

/// Abstracts window discovery and minimizing so `WindowMinimizer`'s
/// filtering logic can be unit tested without touching the real
/// Accessibility API.
protocol AccessibilityWindowProviding {
    func fetchWindows() -> [MinimizableWindow]
    func minimize(_ window: MinimizableWindow)
}
