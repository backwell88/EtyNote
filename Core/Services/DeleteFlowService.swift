import Foundation

struct DeleteResult {
    let deleted: Bool
    let titles: [String]
}

enum DeleteFlowService {
    static func deleteAndReloadTitles(
        word: String,
        in documentsURL: URL
    ) throws -> DeleteResult {
        let deleted = try EntryDeleteService.delete(word: word, in: documentsURL)
        let titles = try MarkdownStoreService.loadTitles(in: documentsURL)
        return DeleteResult(deleted: deleted, titles: titles)
    }
}
