import Foundation

enum MarkdownService {
    static func render(_ entry: WordEntry) -> String {
        """
        ---

        # \(entry.word)

        ## Part of Speech
        \(bullets(entry.partOfSpeech))

        ## English Meaning
        \(bullets(entry.englishMeaning))

        ## Chinese Meaning
        \(bullets(entry.chineseMeaning))

        ## Root
        - Form: \(entry.root.form)
        - Meaning: \(entry.root.meaning)
        - Origin: \(entry.root.originLanguage)

        ## Prefix
        - Form: \(entry.prefix.form)
        - Meaning: \(entry.prefix.meaning)
        - Origin: \(entry.prefix.originLanguage)

        ## Suffix
        - Form: \(entry.suffix.form)
        - Meaning: \(entry.suffix.meaning)
        - Origin: \(entry.suffix.originLanguage)

        ## Related Words
        \(bullets(entry.relatedWords))

        ## Variants
        \(bullets(entry.variants))

        ---

        """
    }

    private static func bullets(_ items: [String]) -> String {
        items.map { "- \($0)" }.joined(separator: "\n")
    }
}
