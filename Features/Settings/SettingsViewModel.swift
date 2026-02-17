import Foundation
import Combine

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var baseURL: String = ""
    @Published var apiKey: String = ""
    @Published var reviewEnabled: Bool = true
    @Published var reviewDailyCountText: String = "10"
    @Published var markdownTransferText: String = ""
    @Published var statusMessage: String = ""

    func load(defaults: UserDefaults = .standard) {
        baseURL = AppConfigService.loadBaseURL(defaults: defaults)
        reviewEnabled = ReviewSettingsService.isReviewEnabled(defaults: defaults)
        reviewDailyCountText = String(ReviewSettingsService.dailyCount(defaults: defaults))

        do {
            apiKey = try KeychainService.loadAPIKey()
        } catch {
            statusMessage = ErrorMessageService.message(for: error)
        }
    }

    func save(defaults: UserDefaults = .standard) async {
        do {
            AppConfigService.saveBaseURL(baseURL, defaults: defaults)
            try KeychainService.saveAPIKey(apiKey)

            let parsed = Int(reviewDailyCountText.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 10
            ReviewSettingsService.setDailyCount(max(1, parsed), defaults: defaults)
            try await ReviewSettingsService.updateReviewEnabled(reviewEnabled, defaults: defaults)

            statusMessage = "Settings saved."
        } catch {
            statusMessage = ErrorMessageService.message(for: error)
        }
    }

    func prepareExportDocument() throws -> MarkdownTextDocument {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let markdown = try MarkdownTransferService.exportMarkdown(in: documentsURL)
        markdownTransferText = markdown
        return MarkdownTextDocument(text: markdown)
    }

    func importMarkdownAppend(from fileURL: URL) {
        do {
            let granted = fileURL.startAccessingSecurityScopedResource()
            defer {
                if granted {
                    fileURL.stopAccessingSecurityScopedResource()
                }
            }

            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let result = try MarkdownTransferService.importMarkdownAppendStrict(from: fileURL, in: documentsURL)
            markdownTransferText = try MarkdownTransferService.exportMarkdown(in: documentsURL)

            if result.importedCount == 0 {
                statusMessage = "Import completed: no new entries (duplicates were skipped)."
            } else {
                statusMessage = "Import completed: added \(result.importedCount), skipped duplicates \(result.skippedDuplicateCount)."
            }
        } catch {
            statusMessage = ErrorMessageService.message(for: error)
        }
    }
}
