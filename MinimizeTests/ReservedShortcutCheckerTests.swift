import XCTest
import KeyboardShortcuts
@testable import Minimize

@MainActor
final class ReservedShortcutCheckerTests: XCTestCase {
    // TC1.4
    func testFlagsKnownSystemShortcut() {
        let shortcut = KeyboardShortcuts.Shortcut(.space, modifiers: [.command])
        XCTAssertTrue(ReservedShortcutChecker.isReserved(shortcut))
    }

    // TC1.5, and confirms the app's own default doesn't collide with itself
    func testDoesNotFlagTheAppsDefaultShortcut() {
        let shortcut = KeyboardShortcuts.Shortcut(.m, modifiers: [.control, .option, .command])
        XCTAssertFalse(ReservedShortcutChecker.isReserved(shortcut))
    }

    func testNilShortcutIsNotReserved() {
        XCTAssertFalse(ReservedShortcutChecker.isReserved(nil))
    }
}

@MainActor
final class ShortcutManagerDefaultTests: XCTestCase {
    // AC1.2: default shortcut is Control+Option+Command+M.
    func testDefaultShortcutIsControlOptionCommandM() {
        let expected = KeyboardShortcuts.Shortcut(.m, modifiers: [.control, .option, .command])
        XCTAssertEqual(KeyboardShortcuts.Name.minimizeAllWindows.defaultShortcut, expected)
    }
}
