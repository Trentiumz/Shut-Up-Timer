import SwiftUI

struct TempSession: Codable, Equatable {
    var tasks: [TaskLog]
    var startTime: Date
    var lasUpdate: Date
    var plannedTime: TimeInterval
    var isPaused: Bool

    var timeLocked: TimeInterval
}

class TempSessionLoader {
    static func getSession() -> TempSession? {
        let data = UserDefaults.standard.data(forKey: "session-in-progress");
        if let liveData = data {
            if let decoded = try? JSONDecoder().decode(TempSession.self, from: liveData) {
                return decoded;
            }
            print("Incorrect Data Type");
            return nil;
        } else {
            return nil;
        }
    }

    static func saveSession(_ session: TempSession) {
        if let encoded = try? JSONEncoder().encode(session) {
            UserDefaults.standard.set(encoded, forKey: "session-in-progress");
        }
    }

    static func clearSession() {
        UserDefaults.standard.removeObject(forKey: "session-in-progress");
    }
}
