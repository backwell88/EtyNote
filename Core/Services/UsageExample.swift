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

    static func runGenerateAndSaveMessage(word: String) async -> String {
        let result = await runGenerateAndSave(word: word)

        switch result {
        case .success(let ok):
            return ok ? "保存成功。" : "保存失败：数据校验未通过。"
        case .failure(let error):
            return ErrorMessageService.message(for: error)
        }
    }
}
