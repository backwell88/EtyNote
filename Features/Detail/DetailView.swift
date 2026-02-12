import SwiftUI

struct DetailView: View {
    let title: String

    @State private var content: String = ""
    @State private var statusMessage: String = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                if content.isEmpty {
                    Text(statusMessage.isEmpty ? "暂无内容。" : statusMessage)
                        .foregroundColor(.secondary)
                } else {
                    Text(content)
                        .font(.system(.body, design: .monospaced))
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding()
        }
        .navigationTitle(title)
        .onAppear(perform: load)
    }

    private func load() {
        do {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            content = try EntryDetailService.loadEntryMarkdown(word: title, in: documentsURL) ?? ""
            if content.isEmpty {
                statusMessage = "未找到该词条内容。"
            }
        } catch {
            statusMessage = ErrorMessageService.message(for: error)
        }
    }
}
