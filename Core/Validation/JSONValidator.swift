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

        // Pragmatic strictness: require all mandatory keys, but ignore extra keys from model output.
        let actualTopKeys = Set(dict.keys)
        guard topLevelKeys.isSubset(of: actualTopKeys) else {
            throw JSONValidatorError.topLevelKeysMismatch(
                expected: Array(topLevelKeys).sorted(),
                actual: Array(actualTopKeys).sorted()
            )
        }

        var normalized: [String: Any] = [:]
        normalized["word"] = stringValue(dict["word"])
        normalized["partOfSpeech"] = try normalizeStringArrayField("partOfSpeech", in: dict)
        normalized["englishMeaning"] = try normalizeStringArrayField("englishMeaning", in: dict)
        normalized["chineseMeaning"] = try normalizeStringArrayField("chineseMeaning", in: dict)
        normalized["relatedWords"] = try normalizeStringArrayField("relatedWords", in: dict)
        normalized["variants"] = try normalizeStringArrayField("variants", in: dict)

        normalized["root"] = try normalizeMorphologyField("root", in: dict)
        normalized["prefix"] = try normalizeMorphologyField("prefix", in: dict)
        normalized["suffix"] = try normalizeMorphologyField("suffix", in: dict)

        let normalizedData = try JSONSerialization.data(withJSONObject: normalized)
        let entry = try JSONDecoder().decode(WordEntry.self, from: normalizedData)

        guard validate(entry) else { throw JSONValidatorError.emptyWord }
        return entry
    }

    static func validate(_ entry: WordEntry) -> Bool {
        let wordOK = !entry.word.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

        return wordOK &&
        hasAtLeastOneItem(entry.partOfSpeech) &&
        hasAtLeastOneItem(entry.englishMeaning) &&
        hasAtLeastOneItem(entry.chineseMeaning) &&
        hasAtLeastOneItem(entry.relatedWords) &&
        hasAtLeastOneItem(entry.variants)
    }

    private static func hasAtLeastOneItem(_ values: [String]) -> Bool {
        !values.isEmpty
    }

    private static func normalizeStringArrayField(
        _ field: String,
        in dict: [String: Any]
    ) throws -> [String] {
        if let values = dict[field] as? [String], !values.isEmpty {
            return values
        }

        if let value = dict[field] as? String {
            return [value]
        }

        throw JSONValidatorError.invalidStringArray(field: field)
    }

    private static func normalizeMorphologyField(
        _ field: String,
        in dict: [String: Any]
    ) throws -> [String: String] {
        guard let sub = dict[field] as? [String: Any] else {
            throw JSONValidatorError.morphologyKeysMismatch(field: field)
        }

        let keys = Set(sub.keys)
        guard morphologyKeys.isSubset(of: keys) else {
            throw JSONValidatorError.morphologyKeysMismatch(field: field)
        }

        return [
            "form": stringValue(sub["form"]),
            "meaning": stringValue(sub["meaning"]),
            "originLanguage": stringValue(sub["originLanguage"])
        ]
    }

    private static func stringValue(_ value: Any?) -> String {
        if let text = value as? String { return text }
        if let value { return String(describing: value) }
        return ""
    }
}
