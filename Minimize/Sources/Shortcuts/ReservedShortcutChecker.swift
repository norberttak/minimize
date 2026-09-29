import KeyboardShortcuts

/// Best-effort detection of shortcuts that collide with common, well-known
/// macOS system shortcuts (AC1.3). This cannot be exhaustive — there is no
/// public API to enumerate every shortcut registered system-wide — so it
/// only flags a small set of widely-used combinations as a courtesy warning.
enum ReservedShortcutChecker {
    @MainActor private static let reserved: Set<KeyboardShortcuts.Shortcut> = [
        .init(.space, modifiers: [.command]),           // Spotlight
        .init(.tab, modifiers: [.command]),              // App Switcher
        .init(.q, modifiers: [.command]),                // Quit
        .init(.three, modifiers: [.command, .shift]),    // Screenshot
        .init(.four, modifiers: [.command, .shift]),     // Screenshot (selection)
        .init(.five, modifiers: [.command, .shift]),     // Screenshot/recording tools
    ]

    @MainActor static func isReserved(_ shortcut: KeyboardShortcuts.Shortcut?) -> Bool {
        guard let shortcut else { return false }
        return reserved.contains(shortcut)
    }
}
