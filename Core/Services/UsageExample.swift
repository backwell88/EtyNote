import Foundation

enum UsageExample {
    static func documentsDirectoryURL() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    static func runGenerateAndSave(word: String) async -> Result<Bool, Error> {
        do {
            let success = try await EntrySaveService.generateAndSave(
                word: word,
                in: documentsDirectoryURL()
            )
            return .success(success)
        } catch {
            return .failure(error)
        }
    }
}
