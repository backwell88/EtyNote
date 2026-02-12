import Foundation
import Combine

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var baseURL: String = ""
    @Published var apiKey: String = ""
    @Published var reviewEnabled: Bool = true
    @Published var reviewDailyCountText: String = "10"
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
}
