import Foundation

enum EntrySaveServiceError: Error {
    case invalidEntryData
}

enum EntrySaveService {
    static func save(_ entry: WordEntry, in documentsURL: URL) throws {
        guard let markdown = EntryPipeline.process(entry) else {
            throw EntrySaveServiceError.invalidEntryData
        }

        try FileService.append(markdown, in: documentsURL)
    }

    static func generateAndSave(
        word: String,
        in documentsURL: URL,
        defaults: UserDefaults = .standard
    ) async throws -> String {
        try await NetworkService.ensureReachable()
        let config = try AppConfigService.loadAIConfig(defaults: defaults)
        let resolvedWord = try DictionaryService.resolveEnglishWord(from: word)
        let entry = try await AIPipelineService.generateEntry(for: resolvedWord, config: config)
        try save(entry, in: documentsURL)
        return entry.word
    }
}
