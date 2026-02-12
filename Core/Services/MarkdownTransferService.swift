import Foundation

enum MarkdownTransferService {
    static func exportMarkdown(in documentsURL: URL) throws -> String {
        try MarkdownStoreService.loadMarkdown(in: documentsURL)
    }

    static func importMarkdownReplace(_ markdown: String, in documentsURL: URL) throws {
        let fm = FileManager.default
        let folderURL = documentsURL.appendingPathComponent(FileService.folderName, isDirectory: true)
        let fileURL = folderURL.appendingPathComponent(FileService.fileName)

        if !fm.fileExists(atPath: folderURL.path) {
            try fm.createDirectory(at: folderURL, withIntermediateDirectories: true)
        }

        try markdown.write(to: fileURL, atomically: true, encoding: .utf8)
    }
}
