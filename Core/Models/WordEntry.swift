import Foundation

struct WordEntry: Codable {
    let word: String
    let partOfSpeech: [String]
    let englishMeaning: [String]
    let chineseMeaning: [String]
    let root: Morphology
    let prefix: Morphology
    let suffix: Morphology
    let relatedWords: [String]
    let variants: [String]
}
