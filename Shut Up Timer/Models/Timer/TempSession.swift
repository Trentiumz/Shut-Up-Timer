import SwiftUI

enum CurSessionManagerType: Codable {
    case noLeaveSessionManager(NoLeaveSessionManager)
    case appBlockSessionManager(AppBlockSessionManager)
    // Add new cases here as you create more CurSessionManager implementations
    
    var manager: any CurSessionManager {
        switch self {
        case .noLeaveSessionManager(let session):
            return session
        case .appBlockSessionManager(let session):
            return session
        }
    }
    
    init(from manager: any CurSessionManager) {
        if let noLeaveSessionManager = manager as? NoLeaveSessionManager {
            self = .noLeaveSessionManager(noLeaveSessionManager)
        } else if let appBlockSessionManager = manager as? AppBlockSessionManager {
            self = .appBlockSessionManager(appBlockSessionManager)
        } else {
            // This should never happen if all CurSessionManager types are handled
            fatalError("Unknown CurSessionManager type: \(type(of: manager))")
        }
    }
}

class TempSessionLoader {
    static func getSession() -> (any CurSessionManager)? {
        let data = UserDefaults.standard.data(forKey: "cur-session-manager");
        if let liveData = data {
            do {
                let decoded = try JSONDecoder().decode(CurSessionManagerType.self, from: liveData)
                return decoded.manager;
            } catch {
                print("Decoding last session failed: \(error)")
                return nil;
            }
        } else {
            return nil;
        }
    }

    static func saveSession(_ session: any CurSessionManager) {
        let sessionWrapper = CurSessionManagerType(from: session)
        if let encoded = try? JSONEncoder().encode(sessionWrapper) {
            UserDefaults.standard.set(encoded, forKey: "cur-session-manager");
        }
    }

    static func clearSession() {
        UserDefaults.standard.removeObject(forKey: "cur-session-manager");
    }
}
