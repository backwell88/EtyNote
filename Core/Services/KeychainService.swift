import Foundation
import Security

enum KeychainServiceError: Error {
    case unhandledStatus(OSStatus)
}

enum KeychainService {
    private static let service = "EtyNote"
    private static let account = "apiKey"

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
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainServiceError.unhandledStatus(status)
        }
    }
}
