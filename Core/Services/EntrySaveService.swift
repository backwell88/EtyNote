import Foundation

enum EntrySaveService {
    static func save(_ entry: WordEntry, in documentsURL: URL) throws -> Bool {
        guard let markdown = EntryPipeline.process(entry) else { return false }
        try FileService.append(markdown, in: documentsURL)
        return true
    }
}
