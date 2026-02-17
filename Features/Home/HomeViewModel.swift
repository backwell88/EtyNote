import Foundation
import Combine
import UIKit

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var inputWord: String = ""
    @Published var isLoading: Bool = false
    @Published var statusMessage: String = ""
    @Published var generatedTitle: String?

    func generateAndSave() async {
        let word = inputWord.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !word.isEmpty else {
            statusMessage = "Please enter an English or Chinese term."
            return
        }

        isLoading = true
        generatedTitle = nil
        defer { isLoading = false }

        do {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let title = try await EntrySaveService.generateAndSave(word: word, in: documentsURL)
            statusMessage = "Saved successfully."
            generatedTitle = title
        } catch {
            print("[HomeViewModel] generateAndSave error:", error)
            statusMessage = ErrorMessageService.message(for: error)
        }
    }

    func pasteFromClipboard() {
        let pasted = UIPasteboard.general.string?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !pasted.isEmpty else {
            statusMessage = "Clipboard is empty."
            return
        }

        inputWord = pasted
        statusMessage = "Pasted from clipboard."
    }
}
