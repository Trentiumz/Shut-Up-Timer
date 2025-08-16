import Foundation

extension FastAPIClient {
    
    struct ScheduleLiveNotifParams: Encodable {
        let timestamp: String
    }
    
    func scheduleLiveActivityNotification(timestamp: Date) async -> Bool {
        do {
            let params = ScheduleLiveNotifParams(
                timestamp: ISO8601DateFormatter().string(from: timestamp)
            )
            
            _ = try await sendAuthenticatedRequest(
                params: params,
                url: fastAPIURL.appendingPathComponent("schedule-live-notif"),
                method: "POST"
            )
            return true
        } catch {
            print("Error scheduling live activity notification: \(error)")
            return false
        }
    }
    
    func cancelLiveActivityNotifications() async -> Bool {
        do {
            _ = try await sendAuthenticatedRequest(
                params: EmptyParams(),
                url: fastAPIURL.appendingPathComponent("cancel-live-notif"),
                method: "POST"
            )
            return true
        } catch {
            print("Error canceling live activity notifications: \(error)")
            return false
        }
    }
}

// MARK: - Helper Types
private struct EmptyParams: Encodable {
    // Empty parameters for endpoints that don't need request body data
}
