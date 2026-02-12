import Foundation

enum IndexService {
    static func extractTitles(from markdown: String) -> [String] {
        markdown
            .split(whereSeparator: \.isNewline)
            .compactMap { line in
                let text = line.trimmingCharacters(in: .whitespaces)
                guard text.hasPrefix("# ") else { return nil }
                return String(text.dropFirst(2)).trimmingCharacters(in: .whitespacesAndNewlines)
            }
    }

    static func search(_ keyword: String, in titles: [String]) -> [String] {
        let query = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return titles }

        return titles.filter {
            $0.range(of: query, options: [.caseInsensitive, .diacriticInsensitive]) != nil
        }
    }
}
