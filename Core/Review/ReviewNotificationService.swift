import Foundation
import UserNotifications

enum ReviewNotificationService {
    static let identifier = "etynote.daily.review"

    static func scheduleDailyReviewNotification(enabled: Bool) async throws {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [identifier])

        guard enabled else { return }

        let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
        guard granted else { return }

        let content = UNMutableNotificationContent()
        content.title = "EtyNote Review"
        content.body = "Time for your daily etymology review."
        content.sound = .default

        var date = DateComponents()
        date.hour = 7
        date.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        try await add(request, center: center)
    }

    private static func add(
        _ request: UNNotificationRequest,
        center: UNUserNotificationCenter
    ) async throws {
        try await withCheckedThrowingContinuation { continuation in
            center.add(request) { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }
}
