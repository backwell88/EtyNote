import Foundation

enum EntryPipeline {
    static func process(_ entry: WordEntry) -> String? {
        guard JSONValidator.validate(entry) else { return nil }
        return MarkdownService.render(entry)
    }
}
