import XCTest
@testable import Minimize

private final class FakeWindowProvider: AccessibilityWindowProviding {
    var windows: [MinimizableWindow] = []
    private(set) var minimizedTokens: [AnyHashable] = []

    func fetchWindows() -> [MinimizableWindow] { windows }

    func minimize(_ window: MinimizableWindow) {
        minimizedTokens.append(window.token)
    }
}

final class WindowMinimizerTests: XCTestCase {
    // AC2.1
    func testMinimizesEligibleWindows() {
        let provider = FakeWindowProvider()
        provider.windows = [
            MinimizableWindow(token: "a", ownerBundleIdentifier: "com.example.a", ownerName: "A", isMinimized: false, canMinimize: true),
            MinimizableWindow(token: "b", ownerBundleIdentifier: "com.example.b", ownerName: "B", isMinimized: false, canMinimize: true),
        ]
        let sut = WindowMinimizer(provider: provider)

        let result = sut.minimizeAllWindows(excludingBundleIdentifiers: [])

        XCTAssertEqual(result.minimizedCount, 2)
        XCTAssertEqual(provider.minimizedTokens.count, 2)
    }

    // AC5.2
    func testSkipsExcludedApps() {
        let provider = FakeWindowProvider()
        provider.windows = [
            MinimizableWindow(token: "a", ownerBundleIdentifier: "com.example.a", ownerName: "A", isMinimized: false, canMinimize: true),
            MinimizableWindow(token: "b", ownerBundleIdentifier: "com.example.excluded", ownerName: "B", isMinimized: false, canMinimize: true),
        ]
        let sut = WindowMinimizer(provider: provider)

        let result = sut.minimizeAllWindows(excludingBundleIdentifiers: ["com.example.excluded"])

        XCTAssertEqual(result.minimizedCount, 1)
        XCTAssertEqual(result.skippedExcludedCount, 1)
        XCTAssertEqual(provider.minimizedTokens, ["a"])
    }

    // AC2.2
    func testSkipsAlreadyMinimizedWindows() {
        let provider = FakeWindowProvider()
        provider.windows = [
            MinimizableWindow(token: "a", ownerBundleIdentifier: "com.example.a", ownerName: "A", isMinimized: true, canMinimize: true),
        ]
        let sut = WindowMinimizer(provider: provider)

        let result = sut.minimizeAllWindows(excludingBundleIdentifiers: [])

        XCTAssertEqual(result.minimizedCount, 0)
        XCTAssertEqual(result.skippedAlreadyMinimizedCount, 1)
        XCTAssertTrue(provider.minimizedTokens.isEmpty)
    }

    // AC2.3
    func testSkipsNonMinimizableWindowsWithoutError() {
        let provider = FakeWindowProvider()
        provider.windows = [
            MinimizableWindow(token: "a", ownerBundleIdentifier: "com.example.a", ownerName: "A", isMinimized: false, canMinimize: false),
        ]
        let sut = WindowMinimizer(provider: provider)

        let result = sut.minimizeAllWindows(excludingBundleIdentifiers: [])

        XCTAssertEqual(result.minimizedCount, 0)
        XCTAssertEqual(result.skippedNonMinimizableCount, 1)
    }

    // TC2.7: no windows open
    func testNoWindowsProducesEmptyResult() {
        let provider = FakeWindowProvider()
        let sut = WindowMinimizer(provider: provider)

        let result = sut.minimizeAllWindows(excludingBundleIdentifiers: [])

        XCTAssertEqual(result, MinimizeResult())
    }

    // AC2.1 + AC2.2 + AC2.3 combined, mirroring a realistic mixed desktop
    func testMixedWindowsAreFilteredIndependently() {
        let provider = FakeWindowProvider()
        provider.windows = [
            MinimizableWindow(token: "eligible", ownerBundleIdentifier: "com.example.a", ownerName: "A", isMinimized: false, canMinimize: true),
            MinimizableWindow(token: "excluded", ownerBundleIdentifier: "com.example.excluded", ownerName: "B", isMinimized: false, canMinimize: true),
            MinimizableWindow(token: "already", ownerBundleIdentifier: "com.example.c", ownerName: "C", isMinimized: true, canMinimize: true),
            MinimizableWindow(token: "nonMinimizable", ownerBundleIdentifier: "com.example.d", ownerName: "D", isMinimized: false, canMinimize: false),
        ]
        let sut = WindowMinimizer(provider: provider)

        let result = sut.minimizeAllWindows(excludingBundleIdentifiers: ["com.example.excluded"])

        XCTAssertEqual(result, MinimizeResult(
            minimizedCount: 1,
            skippedExcludedCount: 1,
            skippedAlreadyMinimizedCount: 1,
            skippedNonMinimizableCount: 1
        ))
        XCTAssertEqual(provider.minimizedTokens, ["eligible"])
    }
}
