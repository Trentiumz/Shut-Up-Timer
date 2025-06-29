import Foundation

enum ClientNotification: Codable, Equatable, Identifiable {
    case friendReq(id: String, sender_id: String, pfp: String, username: String, created_at: Date)
    case devResponse(response: String)
    
    var id: String {
        switch self {
        case .friendReq(let id, _, _, _, _):
            return "friendReq-\(id)"
        case .devResponse(let response):
            return "devResponse-\(response.hashValue)"
        }
    }
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case type
        case id
        case sender_id
        case pfp
        case username
        case created_at
        case response
    }
    
    enum NotificationType: String, Codable {
        case friendReq
        case devResponse
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(NotificationType.self, forKey: .type)
        switch type {
        case .friendReq:
            let id = try container.decode(String.self, forKey: .id)
            let sender_id = try container.decode(String.self, forKey: .sender_id)
            let pfp = try container.decode(String.self, forKey: .pfp)
            let username = try container.decode(String.self, forKey: .username)
            let created_at = try container.decode(Date.self, forKey: .created_at)
            self = .friendReq(id: id, sender_id: sender_id, pfp: pfp, username: username, created_at: created_at)
        case .devResponse:
            let response = try container.decode(String.self, forKey: .response)
            self = .devResponse(response: response)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .friendReq(let id, let sender_id, let pfp, let username, let created_at):
            try container.encode(NotificationType.friendReq, forKey: .type)
            try container.encode(id, forKey: .id)
            try container.encode(sender_id, forKey: .sender_id)
            try container.encode(pfp, forKey: .pfp)
            try container.encode(username, forKey: .username)
            try container.encode(created_at, forKey: .created_at)
        case .devResponse(let response):
            try container.encode(NotificationType.devResponse, forKey: .type)
            try container.encode(response, forKey: .response)
        }
    }
}

class ClientNotificationLoader {
    static let userDefaultsKey = "client-notifications"
    static let suiteName = "group.notifications.io.kd.shutuptimer.shared"
    static var defaultNotifications: [ClientNotification] = []
    
    static func loadNotifications() -> [ClientNotification] {
        guard let sharedDefault = UserDefaults(suiteName: ClientNotificationLoader.suiteName) else {
            print("Failed to load client notifications from shared defaults")
            return []
        }
        let data = sharedDefault.data(forKey: userDefaultsKey)
        if let liveData = data {
            if let decoded = try? JSONDecoder().decode([ClientNotification].self, from: liveData) {
                print("Loaded notifications \(decoded)")
                return decoded
            }
            print("Incorrect Data Type for ClientNotificationsLoader")
            return defaultNotifications
        } else {
            print("No data for ClientNotificationsLoader")
            saveNotifications(defaultNotifications)
            return defaultNotifications
        }
    }
    
    static func saveNotifications(_ notifications: [ClientNotification]) {
        if let encoded = try? JSONEncoder().encode(notifications),
           let sharedDefault = UserDefaults(suiteName: ClientNotificationLoader.suiteName){
            print("Successfully loaded the default, saving \(notifications)")
            sharedDefault.set(encoded, forKey: userDefaultsKey)
        }
    }
}

