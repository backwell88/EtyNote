import Foundation

enum FileService {
    static let folderName = "EtyNote"
    static let fileName = "etynote.md"

    static func append(_ markdown: String, in documentsURL: URL) throws {
        let fm = FileManager.default
        let folderURL = documentsURL.appendingPathComponent(folderName, isDirectory: true)
        let fileURL = folderURL.appendingPathComponent(fileName)

        if !fm.fileExists(atPath: folderURL.path) {
            try fm.createDirectory(at: folderURL, withIntermediateDirectories: true)
        }

        let data = Data(markdown.utf8)

        if !fm.fileExists(atPath: fileURL.path) {
            try data.write(to: fileURL)
            return
        }

        let handle = try FileHandle(forWritingTo: fileURL)
        defer { try? handle.close() }
        try handle.seekToEnd()
        try handle.write(contentsOf: data)
    }
}
