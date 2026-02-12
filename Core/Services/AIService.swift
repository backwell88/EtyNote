import Foundation

struct AIServiceConfig {
    let baseURL: String
    let apiKey: String
    let timeoutSeconds: TimeInterval

    init(baseURL: String, apiKey: String, timeoutSeconds: TimeInterval = 15) {
        self.baseURL = baseURL
        self.apiKey = apiKey
        self.timeoutSeconds = timeoutSeconds
    }
}

enum AIServiceError: Error {
    case emptyAPIKey
    case invalidBaseURL
    case invalidJSONBody
    case invalidHTTPResponse
    case httpStatus(Int)
    case emptyAssistantContent
}

enum AIService {
    static func makeRequest(
        word: String,
        config: AIServiceConfig,
        useRetryPrompt: Bool = false
    ) throws -> URLRequest {
        let key = config.apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !key.isEmpty else { throw AIServiceError.emptyAPIKey }
        guard let url = URL(string: config.baseURL) else { throw AIServiceError.invalidBaseURL }

        let userPrompt = useRetryPrompt
            ? PromptBuilder.retryUserPrompt(for: word)
            : PromptBuilder.userPrompt(for: word)

        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "temperature": 0.2,
            "messages": [
                ["role": "system", "content": PromptBuilder.systemPrompt],
                ["role": "user", "content": userPrompt]
            ]
        ]

        guard JSONSerialization.isValidJSONObject(body) else {
            throw AIServiceError.invalidJSONBody
        }

        var request = URLRequest(url: url, timeoutInterval: config.timeoutSeconds)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        return request
    }

    static func generateRawJSON(
        for word: String,
        config: AIServiceConfig,
        useRetryPrompt: Bool = false
    ) async throws -> String {
        let request = try makeRequest(word: word, config: config, useRetryPrompt: useRetryPrompt)
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw AIServiceError.invalidHTTPResponse
        }
        guard (200..<300).contains(http.statusCode) else {
            throw AIServiceError.httpStatus(http.statusCode)
        }

        let decoded = try JSONDecoder().decode(ChatCompletionsResponse.self, from: data)
        let content = decoded.choices.first?.message.content
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let content, !content.isEmpty else {
            throw AIServiceError.emptyAssistantContent
        }

        return content
    }

    private struct ChatCompletionsResponse: Decodable {
        let choices: [Choice]

        struct Choice: Decodable {
            let message: Message
        }

        struct Message: Decodable {
            let content: String
        }
    }
}
