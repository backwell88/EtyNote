import SwiftUI
import UIKit

struct DetailView: View {
    let title: String

    @State private var rawMarkdown: String = ""
    @State private var blocks: [DetailMarkdownBlock] = []
    @State private var statusMessage: String = ""

    private let highlightPalette: [Color] = [
        Color(hex: "FFE8A3"),
        Color(hex: "FFD9CC"),
        Color(hex: "D9F0C2"),
        Color(hex: "CFEFFF"),
        Color(hex: "E3D8FF"),
        Color(hex: "FFDDEE")
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                if rawMarkdown.isEmpty {
                    Text(statusMessage.isEmpty ? "No content." : statusMessage)
                        .foregroundColor(.secondary)
                } else {
                    ForEach(Array(blocks.enumerated()), id: \.offset) { _, block in
                        blockView(block)
                    }

                    if !statusMessage.isEmpty {
                        Text(statusMessage)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .textSelection(.enabled)
        .navigationTitle(title)
        .toolbar {
            if !rawMarkdown.isEmpty {
                Button("Copy") {
                    UIPasteboard.general.string = rawMarkdown
                    statusMessage = "Markdown copied."
                }
            }
        }
        .onAppear(perform: load)
    }

    @ViewBuilder
    private func blockView(_ block: DetailMarkdownBlock) -> some View {
        switch block {
        case .h1(let text):
            headingView(text: text, fontSize: 30, weight: .bold, bottomSpacing: 10)
        case .h2(let text):
            headingView(text: text, fontSize: 24, weight: .semibold, bottomSpacing: 8)
        case .h3(let text):
            headingView(text: text, fontSize: 20, weight: .semibold, bottomSpacing: 6)
        case .body(let text):
            Text(text)
                .font(.system(size: 17, weight: .regular))
                .lineSpacing(6)
                .frame(maxWidth: .infinity, alignment: .leading)
        case .listItem(let text):
            HStack(alignment: .top, spacing: 6) {
                Text("\u{2022}")
                    .font(.system(size: 17, weight: .regular))

                Text(text)
                    .font(.system(size: 17, weight: .regular))
                    .lineSpacing(6)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        case .horizontalRule:
            Divider()
                .padding(.top, 10)
                .padding(.bottom, 10)
        case .spacer:
            Color.clear.frame(height: 6)
        }
    }

    private func headingView(
        text: String,
        fontSize: CGFloat,
        weight: Font.Weight,
        bottomSpacing: CGFloat
    ) -> some View {
        Text(text)
            .font(.system(size: fontSize, weight: weight))
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(highlightColor(for: text).opacity(0.28))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, bottomSpacing)
    }

    private func highlightColor(for headingText: String) -> Color {
        let index = stableColorIndex(for: headingText, modulo: highlightPalette.count)
        return highlightPalette[index]
    }

    private func stableColorIndex(for text: String, modulo: Int) -> Int {
        guard modulo > 0 else { return 0 }

        var hash: UInt64 = 1469598103934665603
        for byte in text.utf8 {
            hash ^= UInt64(byte)
            hash &*= 1099511628211
        }
        return Int(hash % UInt64(modulo))
    }

    private func load() {
        do {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            rawMarkdown = try EntryDetailService.loadEntryMarkdown(word: title, in: documentsURL) ?? ""
            blocks = DetailMarkdownRenderService.parse(rawMarkdown)

            if rawMarkdown.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                statusMessage = "Entry was not found."
            } else if blocks.isEmpty {
                statusMessage = "No readable markdown content."
            } else {
                statusMessage = ""
            }
        } catch {
            statusMessage = ErrorMessageService.message(for: error)
        }
    }
}

private extension Color {
    init(hex: String) {
        let sanitized = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: sanitized).scanHexInt64(&value)

        let r = Double((value >> 16) & 0xFF) / 255.0
        let g = Double((value >> 8) & 0xFF) / 255.0
        let b = Double(value & 0xFF) / 255.0
        self = Color(.sRGB, red: r, green: g, blue: b, opacity: 1)
    }
}

private enum DetailMarkdownBlock {
    case h1(String)
    case h2(String)
    case h3(String)
    case body(String)
    case listItem(String)
    case horizontalRule
    case spacer
}

private enum DetailMarkdownRenderService {
    static func parse(_ markdown: String) -> [DetailMarkdownBlock] {
        let normalized = markdown.replacingOccurrences(of: "\r\n", with: "\n")
        let lines = normalized.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)

        var blocks: [DetailMarkdownBlock] = []
        var bodyBuffer: [String] = []

        func flushBodyBuffer() {
            guard !bodyBuffer.isEmpty else { return }
            blocks.append(.body(bodyBuffer.joined(separator: "\n")))
            bodyBuffer.removeAll()
        }

        for rawLine in lines {
            let trimmed = rawLine.trimmingCharacters(in: .whitespaces)

            if trimmed.isEmpty {
                flushBodyBuffer()
                appendSpacerIfNeeded(to: &blocks)
                continue
            }

            if trimmed == "---" {
                flushBodyBuffer()
                blocks.append(.horizontalRule)
                continue
            }

            if trimmed.hasPrefix("### ") {
                flushBodyBuffer()
                let title = String(trimmed.dropFirst(4)).trimmingCharacters(in: .whitespacesAndNewlines)
                if title.isEmpty {
                    bodyBuffer.append(rawLine)
                } else {
                    blocks.append(.h3(title))
                }
                continue
            }

            if trimmed.hasPrefix("## ") {
                flushBodyBuffer()
                let title = String(trimmed.dropFirst(3)).trimmingCharacters(in: .whitespacesAndNewlines)
                if title.isEmpty {
                    bodyBuffer.append(rawLine)
                } else {
                    blocks.append(.h2(title))
                }
                continue
            }

            if trimmed.hasPrefix("# ") {
                flushBodyBuffer()
                let title = String(trimmed.dropFirst(2)).trimmingCharacters(in: .whitespacesAndNewlines)
                if title.isEmpty {
                    bodyBuffer.append(rawLine)
                } else {
                    blocks.append(.h1(title))
                }
                continue
            }

            if trimmed.hasPrefix("- ") {
                flushBodyBuffer()
                let item = String(trimmed.dropFirst(2)).trimmingCharacters(in: .whitespacesAndNewlines)
                if item.isEmpty {
                    bodyBuffer.append(rawLine)
                } else {
                    blocks.append(.listItem(item))
                }
                continue
            }

            bodyBuffer.append(rawLine)
        }

        flushBodyBuffer()
        while blocks.last?.isSpacer == true {
            _ = blocks.popLast()
        }
        return blocks
    }

    private static func appendSpacerIfNeeded(to blocks: inout [DetailMarkdownBlock]) {
        guard blocks.last?.isSpacer != true else { return }
        blocks.append(.spacer)
    }
}

private extension DetailMarkdownBlock {
    var isSpacer: Bool {
        if case .spacer = self {
            return true
        }
        return false
    }
}
