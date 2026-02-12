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

            statusMessage = "设置已保存。"
        } catch {
            statusMessage = ErrorMessageService.message(for: error)
        }
    }

    func exportMarkdown() {
        do {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            markdownTransferText = try MarkdownTransferService.exportMarkdown(in: documentsURL)
            statusMessage = markdownTransferText.isEmpty ? "当前没有可导出的内容。" : "导出成功（内容已加载到下方文本框）。"
        } catch {
            statusMessage = ErrorMessageService.message(for: error)
        }
    }

    func importMarkdownReplace() {
        do {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            try MarkdownTransferService.importMarkdownReplace(markdownTransferText, in: documentsURL)
            statusMessage = "导入成功（已替换本地Markdown文件）。"
        } catch {
            statusMessage = ErrorMessageService.message(for: error)
        }
    }
}
