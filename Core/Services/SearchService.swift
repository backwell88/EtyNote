import Foundation

enum SearchService {
    static func searchTitles(
        keyword: String,
        in documentsURL: URL
    ) throws -> [String] {
        let titles = try MarkdownStoreService.loadTitles(in: documentsURL)
        return IndexService.search(keyword, in: titles)
    }
}
