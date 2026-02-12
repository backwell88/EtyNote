import Foundation
import Combine

@MainActor
final class ReviewViewModel: ObservableObject {
    @Published var titles: [String] = []
    @Published var statusMessage: String = ""

    func loadToday() {
        do {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            titles = try DailyReviewService.loadTodayReviewTitles(in: documentsURL)
            statusMessage = titles.isEmpty ? "今天暂无复习内容。" : "今日复习 \(titles.count) 个词。"
        } catch {
            titles = []
            statusMessage = ErrorMessageService.message(for: error)
        }
    }
}
