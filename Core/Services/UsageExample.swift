import Foundation

enum UsageExample {
    static func documentsDirectoryURL() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    static func runGenerateAndSave(word: String) async -> Result<String, Error> {
        do {
            let title = try await EntrySaveService.generateAndSave(
                word: word,
                in: documentsDirectoryURL()
            )
            return .success(title)
        } catch {
            return .failure(error)
        }
    }

    static func runGenerateAndSaveMessage(word: String) async -> String {
        let result = await runGenerateAndSave(word: word)

        switch result {
        case .success(let title):
            return "Saved successfully: \(title)"
        case .failure(let error):
            return ErrorMessageService.message(for: error)
        }
    }
}
