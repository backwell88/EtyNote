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
                // 第3次尝试 = 第二次重试，使用更严格提示词
                let useRetryPrompt = (attempt == 3)
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

        // 兼容 AI 偶尔返回 ```json ... ``` 的情况
        guard trimmed.hasPrefix("```") else { return trimmed }

        let lines = trimmed.split(whereSeparator: \.isNewline).map(String.init)
        guard lines.count >= 3 else { return trimmed }

        return lines
            .dropFirst()
            .dropLast()
            .joined(separator: "\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
