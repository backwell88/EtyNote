import Foundation

enum DetailMarkdownBlock {
    case h1(String)
    case h2(String)
    case h3(String)
    case body(String)
    case listItem(String)
    case horizontalRule
    case spacer
}

enum DetailMarkdownRenderService {
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
