import Foundation

enum EntrySaveService {
    static func save(_ entry: WordEntry, in documentsURL: URL) throws -> Bool {
        guard let markdown = EntryPipeline.process(entry) else { return false }
        try FileService.append(markdown, in: documentsURL)
        return true
    }

    static func generateAndSave(
        word: String,
        config: AIServiceConfig,
        in documentsURL: URL
    ) async throws -> Bool {
        let entry = try await AIPipelineService.generateEntry(for: word, config: config)
        return try save(entry, in: documentsURL)
    }
}
