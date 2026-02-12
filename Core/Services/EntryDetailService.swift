import Foundation

enum EntryDetailService {
    static func loadEntryMarkdown(word: String, in documentsURL: URL) throws -> String? {
        let target = word.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !target.isEmpty else { return nil }

        let markdown = try MarkdownStoreService.loadMarkdown(in: documentsURL)
        for block in splitBlocks(in: markdown) {
            if extractTitle(from: block).lowercased() == target {
                return block + "\n"
            }
        }
        return nil
    }

    private static func splitBlocks(in markdown: String) -> [String] {
        let lines = markdown
            .replacingOccurrences(of: "\r\n", with: "\n")
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map(String.init)

        var result: [String] = []
        var i = 0

        while i < lines.count {
            if lines[i].trimmingCharacters(in: .whitespaces) == "---" {
                var j = i + 1
                while j < lines.count && lines[j].trimmingCharacters(in: .whitespaces) != "---" {
                    j += 1
                }
                if j < lines.count {
                    result.append(lines[i...j].joined(separator: "\n"))
                    i = j + 1
                    continue
                }
            }
            i += 1
        }

        return result
    }

    private static func extractTitle(from block: String) -> String {
        for line in block.split(whereSeparator: \.isNewline) {
            let text = line.trimmingCharacters(in: .whitespaces)
            if text.hasPrefix("# ") {
                return String(text.dropFirst(2)).trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        return ""
    }
}
