import XCTest
@testable import Minimize

final class ExclusionListStoreTests: XCTestCase {
    private let suiteName = "ExclusionListStoreTests"
    private var defaults: UserDefaults!

    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: suiteName)
        defaults.removePersistentDomain(forName: suiteName)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        defaults = nil
        super.tearDown()
    }

    func testStartsEmpty() {
        let sut = ExclusionListStore(defaults: defaults)
        XCTAssertTrue(sut.excludedBundleIdentifiers.isEmpty)
    }

    // AC5.1/AC5.2
    func testExcludeAddsBundleIdentifier() {
        let sut = ExclusionListStore(defaults: defaults)
        sut.exclude("com.example.app")
        XCTAssertTrue(sut.isExcluded("com.example.app"))
    }

    // TC5.3
    func testIncludeRemovesBundleIdentifier() {
        let sut = ExclusionListStore(defaults: defaults)
        sut.exclude("com.example.app")
        sut.include("com.example.app")
        XCTAssertFalse(sut.isExcluded("com.example.app"))
    }

    // AC5.3
    func testExclusionsPersistAcrossInstances() {
        let first = ExclusionListStore(defaults: defaults)
        first.exclude("com.example.app")

        let second = ExclusionListStore(defaults: defaults)
        XCTAssertTrue(second.isExcluded("com.example.app"))
    }

    func testExcludingEmptyStringIsNoOp() {
        let sut = ExclusionListStore(defaults: defaults)
        sut.exclude("")
        XCTAssertTrue(sut.excludedBundleIdentifiers.isEmpty)
    }
}
