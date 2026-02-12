import Foundation
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var inputWord: String = ""
    @Published var isLoading: Bool = false
    @Published var statusMessage: String = ""

    func generateAndSave() async {
        let word = inputWord.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !word.isEmpty else {
            statusMessage = "请输入单词或中文词。"
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let ok = try await EntrySaveService.generateAndSave(word: word, in: documentsURL)
            statusMessage = ok ? "保存成功。" : "保存失败：数据校验未通过。"
        } catch {
            print("[HomeViewModel] generateAndSave error:", error)
            statusMessage = ErrorMessageService.message(for: error)
        }
    }
}
