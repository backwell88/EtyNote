import Foundation
import Security

enum KeychainServiceError: Error {
    case unhandledStatus(OSStatus)
}

enum KeychainService {
    private static let service = "EtyNote"
    private static let account = "apiKey"
    private static let simulatorFallbackKey = "settings.apiKey.simulatorFallback"

    static func saveAPIKey(_ key: String) throws {
        let data = Data(key.utf8)
        try deleteAPIKeyIfExists()

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        #if targetEnvironment(simulator)
        if status == errSecMissingEntitlement {
            UserDefaults.standard.set(key, forKey: simulatorFallbackKey)
            return
        }
        #endif

        guard status == errSecSuccess else {
            throw KeychainServiceError.unhandledStatus(status)
        }
    }

    static func loadAPIKey() throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        if status == errSecItemNotFound { return "" }

        #if targetEnvironment(simulator)
        if status == errSecMissingEntitlement {
            return UserDefaults.standard.string(forKey: simulatorFallbackKey) ?? ""
        }
        #endif

        guard status == errSecSuccess else {
            throw KeychainServiceError.unhandledStatus(status)
        }

        guard let data = item as? Data else { return "" }
        return String(data: data, encoding: .utf8) ?? ""
    }

    static func deleteAPIKeyIfExists() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        let status = SecItemDelete(query as CFDictionary)

        #if targetEnvironment(simulator)
        if status == errSecMissingEntitlement {
            UserDefaults.standard.removeObject(forKey: simulatorFallbackKey)
            return
        }
        #endif

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainServiceError.unhandledStatus(status)
        }
    }
}
