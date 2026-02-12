import Foundation
import Network

enum NetworkServiceError: Error {
    case noNetwork
}

enum NetworkService {
    static func ensureReachable() async throws {
        let reachable = await isReachable()
        guard reachable else { throw NetworkServiceError.noNetwork }
    }

    static func isReachable(timeoutSeconds: TimeInterval = 2) async -> Bool {
        await withCheckedContinuation { continuation in
            let monitor = NWPathMonitor()
            let queue = DispatchQueue(label: "EtyNote.NetworkMonitor")
            var resumed = false

            func finish(_ value: Bool) {
                guard !resumed else { return }
                resumed = true
                monitor.cancel()
                continuation.resume(returning: value)
            }

            monitor.pathUpdateHandler = { path in
                finish(path.status == .satisfied)
            }

            monitor.start(queue: queue)

            queue.asyncAfter(deadline: .now() + timeoutSeconds) {
                finish(false)
            }
        }
    }
}
