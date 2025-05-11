import Foundation

struct SessionEntry: Identifiable, Codable, Equatable {
    var id = UUID()
    var todoID: UUID
    var started: Date
    var ended: Date
    var timeLocked: TimeInterval
    var success: Bool
}

class Sessions : Codable, Equatable, ObservableObject {
    @Published var sessions: [SessionEntry];

    init(sessions: [SessionEntry]) {
        self.sessions = sessions;
    }
    
    static func == (l: Sessions, r: Sessions) -> Bool {
        return l.sessions == r.sessions;
    }
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case sessions;
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self);
        sessions = try container.decode([SessionEntry].self, forKey: .sessions);
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self);
        try container.encode(sessions, forKey: .sessions);
    }

    func getIQ() -> Int {
        if let liveSession = sessions {
            var cIq: Int = 0;
            for session in liveSession {
                if session.success {
                    cIq += session.timeLocked;
                } else {
                    cIq -= 1;
                }
            }
            return cIq;
        } else {
            return 0;
        }
    }

    func getTimeLocked() -> Int {
        if let liveSession = sessions {
            let totTime: Int = liveSession.reduce(0) { $0 + Int($1.timeLocked) };
            return totTime;
        } else {
            return 0;
        }
    }
}

class SessionsLoader {
    static var defaultSessions: Sessions = Sessions(sessions: []);

    static func loadSettings() -> Sessions {
        let data = UserDefaults.standard.data(forKey: "user-sessions");
        if let liveData = data {
            if let decoded = try? JSONDecoder().decode(Sessions.self, from: liveData) {
                return decoded;
            }
            print("Incorrect Data Type");
            return defaultSessions;
        } else {
            saveSettings(defaultSessions);
            return defaultSessions;
        }
    }
    
    static func saveSettings(_ sessions: Sessions) {
        if let encoded = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(encoded, forKey: "user-sessions");
        }
    }
}
