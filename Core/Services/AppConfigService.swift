import Foundation

enum AppConfigServiceError: Error {
    case emptyAPIKey
    case emptyBaseURL
}

enum AppConfigService {
    static let baseURLKey = "settings.baseURL"

    static func saveBaseURL(_ baseURL: String, defaults: UserDefaults = .standard) {
        defaults.set(baseURL, forKey: baseURLKey)
    }

    static func loadBaseURL(defaults: UserDefaults = .standard) -> String {
        let value = defaults.string(forKey: baseURLKey)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        return value.isEmpty
            ? "https://api.openai.com/v1/chat/completions"
            : value
    }

    static func loadAIConfig(
        apiKey: String,
        defaults: UserDefaults = .standard
    ) throws -> AIServiceConfig {
        let cleanedKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanedKey.isEmpty else { throw AppConfigServiceError.emptyAPIKey }

        let baseURL = loadBaseURL(defaults: defaults)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !baseURL.isEmpty else { throw AppConfigServiceError.emptyBaseURL }

        return AIServiceConfig(baseURL: baseURL, apiKey: cleanedKey)
    }
}
