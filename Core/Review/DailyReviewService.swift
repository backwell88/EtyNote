import Foundation

enum DailyReviewService {
    static func loadTodayReviewTitles(
        in documentsURL: URL,
        defaults: UserDefaults = .standard
    ) throws -> [String] {
        guard ReviewSettingsService.isReviewEnabled(defaults: defaults) else {
            return []
        }

        let count = ReviewSettingsService.dailyCount(defaults: defaults)
        return try ReviewManager.loadDailyTitles(count: count, in: documentsURL)
    }
}
