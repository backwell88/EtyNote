import Foundation

enum DictionaryServiceError: Error {
    case noMatch
}

enum DictionaryService {
    // 最小可用：先用内置映射，后续可替换为真实词典服务
    private static let builtinMap: [String: String] = [
        "建筑": "construct",
        "结构": "structure",
        "词根": "root",
        "词源": "etymology",
        "语言": "language"
    ]

    static func containsChinese(_ text: String) -> Bool {
        text.unicodeScalars.contains { scalar in
            (0x4E00...0x9FFF).contains(Int(scalar.value))
        }
    }

    static func resolveEnglishWord(from input: String) throws -> String {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw DictionaryServiceError.noMatch }

        if !containsChinese(trimmed) {
            return trimmed.lowercased()
        }

        if let mapped = builtinMap[trimmed] {
            return mapped
        }

        throw DictionaryServiceError.noMatch
    }
}
