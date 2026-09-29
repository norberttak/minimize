import Foundation

/// Persists the set of app bundle identifiers the user has chosen to
/// exclude from the minimize action (requirement R5).
final class ExclusionListStore: ObservableObject {
    private static let defaultsKey = "excludedBundleIdentifiers"

    @Published private(set) var excludedBundleIdentifiers: Set<String>

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let stored = defaults.array(forKey: Self.defaultsKey) as? [String] ?? []
        self.excludedBundleIdentifiers = Set(stored)
    }

    func isExcluded(_ bundleIdentifier: String) -> Bool {
        excludedBundleIdentifiers.contains(bundleIdentifier)
    }

    func exclude(_ bundleIdentifier: String) {
        guard !bundleIdentifier.isEmpty else { return }
        excludedBundleIdentifiers.insert(bundleIdentifier)
        persist()
    }

    func include(_ bundleIdentifier: String) {
        excludedBundleIdentifiers.remove(bundleIdentifier)
        persist()
    }

    private func persist() {
        defaults.set(Array(excludedBundleIdentifiers), forKey: Self.defaultsKey)
    }
}
