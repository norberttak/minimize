import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    /// AC1.2: default shortcut is Control+Option+Command+M.
    @MainActor static let minimizeAllWindows = Self(
        "minimizeAllWindows",
        default: .init(.m, modifiers: [.control, .option, .command])
    )
}

/// Registers the global shortcut (R1) and forwards presses to a handler.
/// Recording/persisting a custom shortcut (R4) is handled by
/// `KeyboardShortcuts.Recorder` directly in Settings; this type only wires
/// up the trigger side.
@MainActor
final class ShortcutManager {
    init(onTrigger: @escaping () -> Void) {
        KeyboardShortcuts.onKeyUp(for: .minimizeAllWindows) {
            onTrigger()
        }
    }
}
