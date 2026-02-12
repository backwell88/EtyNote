import Foundation

enum JSONValidator {
    static func validate(_ entry: WordEntry) -> Bool {
        !entry.word.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !entry.partOfSpeech.isEmpty &&
        !entry.englishMeaning.isEmpty &&
        !entry.chineseMeaning.isEmpty &&
        !entry.relatedWords.isEmpty &&
        !entry.variants.isEmpty
    }
}
