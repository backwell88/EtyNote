import Foundation

enum EntryDeleteService {
    static func delete(word: String, in documentsURL: URL) throws -> Bool {
        let target = word.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !target.isEmpty else { return false }

        let original = try MarkdownStoreService.loadMarkdown(in: documentsURL)
        guard !original.isEmpty else { return false }

        let blocks = splitBlocks(in: original)
        guard !blocks.isEmpty else { return false }

        var removed = false
        var kept: [String] = []

        for block in blocks {
            let title = extractTitle(from: block).lowercased()
            if !removed && title == target {
                removed = true
                continue
            }
            kept.append(block)
        }

        guard removed else { return false }

        let newMarkdown = kept.isEmpty ? "" : kept.joined(separator: "\n\n") + "\n"
        let url = MarkdownStoreService.fileURL(in: documentsURL)
        try newMarkdown.write(to: url, atomically: true, encoding: .utf8)
        return true
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
