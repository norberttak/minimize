import XCTest
@testable import Minimize

private final class FakeAccessibilityChecker: AccessibilityPermissionChecking {
    var trusted = false
    private(set) var promptedCount = 0

    func isTrusted(promptIfNeeded: Bool) -> Bool {
        if promptIfNeeded {
            promptedCount += 1
        }
        return trusted
    }
}

@MainActor
final class AccessibilityPermissionManagerTests: XCTestCase {
    func testReflectsInitialTrustState() {
        let checker = FakeAccessibilityChecker()
        checker.trusted = true

        let sut = AccessibilityPermissionManager(checker: checker)

        XCTAssertTrue(sut.isTrusted)
    }

    // AC7.3: detects a grant made outside the app without a relaunch.
    func testRefreshPicksUpGrantedPermission() {
        let checker = FakeAccessibilityChecker()
        let sut = AccessibilityPermissionManager(checker: checker)
        XCTAssertFalse(sut.isTrusted)

        checker.trusted = true
        sut.refresh()

        XCTAssertTrue(sut.isTrusted)
    }

    // AC7.1
    func testRequestPermissionPromptsAndRefreshesState() {
        let checker = FakeAccessibilityChecker()
        let sut = AccessibilityPermissionManager(checker: checker)

        checker.trusted = true
        sut.requestPermission()

        XCTAssertEqual(checker.promptedCount, 1)
        XCTAssertTrue(sut.isTrusted)
    }
}
