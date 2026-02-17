import Foundation

enum AIPipelineError: Error {
    case invalidAssistantJSON
    case schemaValidationFailed
    case failedAfterRetryLimit(lastErrorDescription: String)
}

enum AIPipelineService {
    static func generateEntry(for word: String, config: AIServiceConfig) async throws -> WordEntry {
        var lastErrorDescription = "unknown"

        for attempt in 1...3 {
            do {
                // 第2/3次尝试均启用更严格提示词，提高不合规输出修复概率
                let useRetryPrompt = (attempt >= 2)
                let raw = try await AIService.generateRawJSON(
                    for: word,
                    config: config,
                    useRetryPrompt: useRetryPrompt
                )

                let normalized = normalize(raw)
                guard let data = normalized.data(using: .utf8) else {
                    throw AIPipelineError.invalidAssistantJSON
                }

                let entry = try JSONValidator.decodeStrict(from: data)
                guard JSONValidator.validate(entry) else {
                    throw AIPipelineError.schemaValidationFailed
                }

                return entry
            } catch {
                lastErrorDescription = String(describing: error)
                print("[AIPipelineService] attempt \(attempt) failed:", error)

                if attempt == 3 {
                    throw AIPipelineError.failedAfterRetryLimit(lastErrorDescription: lastErrorDescription)
                }
            }
        }

        throw AIPipelineError.failedAfterRetryLimit(lastErrorDescription: lastErrorDescription)
    }

    private static func normalize(_ text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let deFenced = stripCodeFenceIfNeeded(trimmed)
        if let object = extractJSONObject(from: deFenced) {
            return object
        }
        return deFenced
    }

    private static func stripCodeFenceIfNeeded(_ text: String) -> String {
        guard text.hasPrefix("```") else { return text }

        let lines = text.split(whereSeparator: \.isNewline).map(String.init)
        guard lines.count >= 3 else { return text }

        return lines
            .dropFirst()
            .dropLast()
            .joined(separator: "\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func extractJSONObject(from text: String) -> String? {
        guard let firstBrace = text.firstIndex(of: "{"),
              let lastBrace = text.lastIndex(of: "}"),
              firstBrace <= lastBrace else {
            return nil
        }

        return String(text[firstBrace...lastBrace])
    }
}
