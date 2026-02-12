import Foundation

enum MarkdownStoreService {
    static func fileURL(in documentsURL: URL) -> URL {
        documentsURL
            .appendingPathComponent(FileService.folderName, isDirectory: true)
            .appendingPathComponent(FileService.fileName)
    }

    static func loadMarkdown(in documentsURL: URL) throws -> String {
        let url = fileURL(in: documentsURL)
        guard FileManager.default.fileExists(atPath: url.path) else {
            return ""
        }
        return try String(contentsOf: url, encoding: .utf8)
    }

    static func loadTitles(in documentsURL: URL) throws -> [String] {
        let markdown = try loadMarkdown(in: documentsURL)
        return IndexService.extractTitles(from: markdown)
    }
}
