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

        let url = try resolveCompletionsURL(from: config.baseURL)

        let userPrompt = useRetryPrompt
            ? PromptBuilder.retryUserPrompt(for: word)
            : PromptBuilder.userPrompt(for: word)

        let body: [String: Any] = [
            "model": resolveModel(from: url),
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

    private static func resolveModel(from url: URL) -> String {
        let host = (url.host ?? "").lowercased()
        if host.contains("deepseek.com") {
            return "deepseek-chat"
        }
        return "gpt-4o-mini"
    }

    private static func resolveCompletionsURL(from base: String) throws -> URL {
        let trimmed = base.trimmingCharacters(in: .whitespacesAndNewlines)
        guard var components = URLComponents(string: trimmed), components.scheme != nil, components.host != nil else {
            throw AIServiceError.invalidBaseURL
        }

        let normalizedPath = components.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))

        if normalizedPath.isEmpty {
            // e.g. https://api.deepseek.com or https://api.openai.com
            components.path = components.host?.contains("openai.com") == true
                ? "/v1/chat/completions"
                : "/chat/completions"
        } else if normalizedPath == "v1" {
            // e.g. https://api.deepseek.com/v1
            components.path = "/v1/chat/completions"
        } else if normalizedPath == "chat/completions" || normalizedPath == "v1/chat/completions" {
            // already full endpoint, keep as-is
        } else {
            // Unknown path; use it directly, but still valid URL.
        }

        guard let url = components.url else {
            throw AIServiceError.invalidBaseURL
        }
        return url
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
