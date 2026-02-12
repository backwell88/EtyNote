import Foundation

enum JSONValidatorError: Error {
    case invalidJSONObject
    case topLevelKeysMismatch(expected: [String], actual: [String])
    case morphologyKeysMismatch(field: String)
    case invalidStringArray(field: String)
    case emptyWord
}

enum JSONValidator {
    private static let topLevelKeys: Set<String> = [
        "word",
        "partOfSpeech",
        "englishMeaning",
        "chineseMeaning",
        "root",
        "prefix",
        "suffix",
        "relatedWords",
        "variants"
    ]

    private static let morphologyKeys: Set<String> = [
        "form",
        "meaning",
        "originLanguage"
    ]

    static func decodeStrict(from data: Data) throws -> WordEntry {
        let object = try JSONSerialization.jsonObject(with: data)
        guard let dict = object as? [String: Any] else {
            throw JSONValidatorError.invalidJSONObject
        }

        let actualTopKeys = Set(dict.keys)
        guard actualTopKeys == topLevelKeys else {
            throw JSONValidatorError.topLevelKeysMismatch(
                expected: Array(topLevelKeys).sorted(),
                actual: Array(actualTopKeys).sorted()
            )
        }

        try validateStringArrayField("partOfSpeech", in: dict)
        try validateStringArrayField("englishMeaning", in: dict)
        try validateStringArrayField("chineseMeaning", in: dict)
        try validateStringArrayField("relatedWords", in: dict)
        try validateStringArrayField("variants", in: dict)

        try validateMorphologyField("root", in: dict)
        try validateMorphologyField("prefix", in: dict)
        try validateMorphologyField("suffix", in: dict)

        let entry = try JSONDecoder().decode(WordEntry.self, from: data)
        guard validate(entry) else { throw JSONValidatorError.emptyWord }
        return entry
    }

    static func validate(_ entry: WordEntry) -> Bool {
        let wordOK = !entry.word.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

        return wordOK &&
        isNonEmptyStringArray(entry.partOfSpeech) &&
        isNonEmptyStringArray(entry.englishMeaning) &&
        isNonEmptyStringArray(entry.chineseMeaning) &&
        isNonEmptyStringArray(entry.relatedWords) &&
        isNonEmptyStringArray(entry.variants)
    }

    private static func isNonEmptyStringArray(_ values: [String]) -> Bool {
        !values.isEmpty &&
        values.allSatisfy { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }

    private static func validateStringArrayField(_ field: String, in dict: [String: Any]) throws {
        guard let values = dict[field] as? [String], isNonEmptyStringArray(values) else {
            throw JSONValidatorError.invalidStringArray(field: field)
        }
    }

    private static func validateMorphologyField(_ field: String, in dict: [String: Any]) throws {
        guard let sub = dict[field] as? [String: Any] else {
            throw JSONValidatorError.morphologyKeysMismatch(field: field)
        }
        guard Set(sub.keys) == morphologyKeys else {
            throw JSONValidatorError.morphologyKeysMismatch(field: field)
        }
    }
}
