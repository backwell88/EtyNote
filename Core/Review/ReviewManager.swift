import Foundation

enum ReviewManager {
    static func pickDailyTitles(
        from titles: [String],
        count: Int
    ) -> [String] {
        let safeCount = max(0, count)
        guard safeCount > 0, !titles.isEmpty else { return [] }

        return Array(titles.shuffled().prefix(safeCount))
    }

    static func loadDailyTitles(
        count: Int,
        in documentsURL: URL
    ) throws -> [String] {
        let titles = try MarkdownStoreService.loadTitles(in: documentsURL)
        return pickDailyTitles(from: titles, count: count)
    }
}
