import SwiftUI
import UIKit

struct DetailView: View {
    let title: String

    @State private var content: String = ""
    @State private var statusMessage: String = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                if content.isEmpty {
                    Text(statusMessage.isEmpty ? "No content." : statusMessage)
                        .foregroundColor(.secondary)
                } else {
                    Text(content)
                        .font(.system(.body, design: .monospaced))
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if !statusMessage.isEmpty {
                        Text(statusMessage)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
        }
        .navigationTitle(title)
        .toolbar {
            if !content.isEmpty {
                Button("Copy") {
                    UIPasteboard.general.string = content
                    statusMessage = "Markdown copied."
                }
            }
        }
        .onAppear(perform: load)
    }

    private func load() {
        do {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            content = try EntryDetailService.loadEntryMarkdown(word: title, in: documentsURL) ?? ""
            if content.isEmpty {
                statusMessage = "Entry was not found."
            } else {
                statusMessage = ""
            }
        } catch {
            statusMessage = ErrorMessageService.message(for: error)
        }
    }
}
