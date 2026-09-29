import SwiftUI

/// The menu bar label (F3). Shows a warning glyph when Accessibility
/// permission is missing, so shortcut failures are visible (AC7.2).
struct MenuBarIcon: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        Image(systemName: appState.permissionManager.isTrusted
            ? "rectangle.compress.vertical"
            : "exclamationmark.triangle")
    }
}
