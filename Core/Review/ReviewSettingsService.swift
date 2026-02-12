import Foundation

enum ReviewSettingsService {
    private static let enabledKey = "settings.review.enabled"
    private static let dailyCountKey = "settings.review.dailyCount"

    static func setReviewEnabled(_ enabled: Bool, defaults: UserDefaults = .standard) {
        defaults.set(enabled, forKey: enabledKey)
    }

    static func isReviewEnabled(defaults: UserDefaults = .standard) -> Bool {
        if defaults.object(forKey: enabledKey) == nil {
            return true
        }
        return defaults.bool(forKey: enabledKey)
    }

    static func setDailyCount(_ count: Int, defaults: UserDefaults = .standard) {
        defaults.set(max(1, count), forKey: dailyCountKey)
    }

    static func dailyCount(defaults: UserDefaults = .standard) -> Int {
        let raw = defaults.integer(forKey: dailyCountKey)
        return raw <= 0 ? 10 : raw
    }
}
