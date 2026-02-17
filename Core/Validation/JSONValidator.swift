import Foundation

enum JSONValidatorError: Error {
    case invalidJSONObject
    case topLevelKeysMismatch(expected: [String], actual: [String])
    case morphologyKeysMismatch(field: String)
    case invalidStringArray(field: String)
    case emptyWord
}

enum JSONValidator {
    static func decodeStrict(from data: Data) throws -> WordEntry {
        let object = try JSONSerialization.jsonObject(with: data)
        guard let dict = object as? [String: Any] else {
            throw JSONValidatorError.invalidJSONObject
        }

        let actualTopKeys = Set(dict.keys)
        guard actualTopKeys.contains("word") else {
            throw JSONValidatorError.topLevelKeysMismatch(
                expected: ["word"],
                actual: Array(actualTopKeys).sorted()
            )
        }

        var normalized: [String: Any] = [:]
        normalized["word"] = stringValue(dict["word"]).trimmingCharacters(in: .whitespacesAndNewlines)
        normalized["partOfSpeech"] = normalizeStringArrayField("partOfSpeech", in: dict)
        normalized["englishMeaning"] = normalizeStringArrayField("englishMeaning", in: dict)
        normalized["chineseMeaning"] = normalizeStringArrayField("chineseMeaning", in: dict)
        normalized["relatedWords"] = normalizeStringArrayField("relatedWords", in: dict)
        normalized["variants"] = normalizeStringArrayField("variants", in: dict)

        normalized["root"] = normalizeMorphologyField("root", in: dict)
        normalized["prefix"] = normalizeMorphologyField("prefix", in: dict)
        normalized["suffix"] = normalizeMorphologyField("suffix", in: dict)

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
        values.contains { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }

    private static func normalizeStringArrayField(
        _ field: String,
        in dict: [String: Any]
    ) -> [String] {
        if let values = dict[field] as? [Any] {
            let normalized = values
                .map { stringValue($0).trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
            if !normalized.isEmpty {
                return normalized
            }
        }

        if let value = dict[field] {
            let normalized = stringValue(value).trimmingCharacters(in: .whitespacesAndNewlines)
            if !normalized.isEmpty {
                return [normalized]
            }
        }

        return ["N/A"]
    }

    private static func normalizeMorphologyField(
        _ field: String,
        in dict: [String: Any]
    ) -> [String: String] {
        if let sub = dict[field] as? [String: Any] {
            return [
                "form": nonEmptyOrNA(sub["form"]),
                "meaning": nonEmptyOrNA(sub["meaning"]),
                "originLanguage": nonEmptyOrNA(sub["originLanguage"])
            ]
        }

        if let value = dict[field] {
            let normalized = stringValue(value).trimmingCharacters(in: .whitespacesAndNewlines)
            if !normalized.isEmpty {
                return [
                    "form": normalized,
                    "meaning": "N/A",
                    "originLanguage": "N/A"
                ]
            }
        }

        return [
            "form": "N/A",
            "meaning": "N/A",
            "originLanguage": "N/A"
        ]
    }

    private static func nonEmptyOrNA(_ value: Any?) -> String {
        let normalized = stringValue(value).trimmingCharacters(in: .whitespacesAndNewlines)
        return normalized.isEmpty ? "N/A" : normalized
    }

    private static func stringValue(_ value: Any?) -> String {
        if let text = value as? String { return text }
        if let value { return String(describing: value) }
        return ""
    }
}
