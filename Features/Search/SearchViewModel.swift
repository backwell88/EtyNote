import Foundation
import Combine

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var keyword: String = ""
    @Published var titles: [String] = []
    @Published var filteredTitles: [String] = []
    @Published var statusMessage: String = ""

    func loadTitles() {
        do {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            titles = try MarkdownStoreService.loadTitles(in: documentsURL)
            filteredTitles = IndexService.search(keyword, in: titles)
            statusMessage = titles.isEmpty ? "暂无词条。" : "已加载 \(titles.count) 条词条。"
        } catch {
            titles = []
            filteredTitles = []
            statusMessage = ErrorMessageService.message(for: error)
        }
    }

    func search() {
        filteredTitles = IndexService.search(keyword, in: titles)
    }

    func delete(word: String) {
        do {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let result = try DeleteFlowService.deleteAndReloadTitles(word: word, in: documentsURL)
            titles = result.titles
            filteredTitles = IndexService.search(keyword, in: titles)
            statusMessage = result.deleted ? "删除成功。" : "未找到要删除的词条。"
        } catch {
            statusMessage = ErrorMessageService.message(for: error)
        }
    }
}
