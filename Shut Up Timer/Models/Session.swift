import Foundation

struct TaskLog: Identifiable, Codable, Equatable{
    var id = UUID()
    var todoID: UUID
    var timeIn: TimeInterval
}

struct SessionEntry: Identifiable, Codable, Equatable {
    var id = UUID()
    var tasks: [TaskLog]
    var started: Date
    var ended: Date
    var timeLocked: TimeInterval
    var plannedTime: TimeInterval
    var success: Bool
    var roast: String?
    var imageName: String?
    
    var iqChange: Double { success ? (plannedTime <= 3600 ? plannedTime / 3600 : 1 + 2 * (plannedTime - 3600) / 3600) : -1 }
    var sortedCategories: [(todoID: UUID, time: TimeInterval)] {
        // Create a dictionary to store total seconds per todoID
        var categorySeconds: [UUID: TimeInterval] = [:]
        
        // Calculate total seconds for each todoID
        for taskLog in self.tasks {
            let seconds = taskLog.timeIn
            categorySeconds[taskLog.todoID, default: 0] += seconds
        }
        
        // Convert dictionary to array of tuples and sort by seconds
        let sortedCategories = categorySeconds.map { (todoID: $0.key, time: $0.value) }
            .sorted { $0.time > $1.time }
        
        return sortedCategories
    }
    
}

class Sessions : Codable, Equatable, ObservableObject {
    @Published var sessions: [SessionEntry] = [] {
        didSet {
            onUpdate(self);
        }
    }
    var onUpdate: (_: Sessions) -> Void = { _ in };

    init(sessions: [SessionEntry], onUpdate: @escaping (_: Sessions) -> Void = { _ in }) {
        self.sessions = sessions;
        self.onUpdate = onUpdate;
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
        onUpdate = {_ in }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self);
        try container.encode(sessions, forKey: .sessions);
    }

    func getIQ() -> Double {
        var cIq: Double = 0;
        for session in sessions {
            cIq += session.iqChange;
        }
        return cIq;
    }

    func getTotalTimeLocked() -> Int {
        let totTime: Int = sessions.reduce(0) { $0 + Int($1.timeLocked) };
        return totTime;
    }

    func getTopCategories() -> [(todoID: UUID, seconds: Int)] {
        // Create a dictionary to store total seconds per todoID
        var categorySeconds: [UUID: Int] = [:]
        
        // Calculate total seconds for each todoID
        for session in sessions {
            for taskLog in session.tasks {
                let seconds = Int(taskLog.timeIn) 
                categorySeconds[taskLog.todoID, default: 0] += seconds
            }
        }
        
        // Convert dictionary to array of tuples and sort by seconds
        let sortedCategories = categorySeconds.map { (todoID: $0.key, seconds: $0.value) }
            .sorted { $0.seconds > $1.seconds }
        
        return sortedCategories
    }

    func getTopCategoryStrings(toDoList: ToDoListV2) -> [String] {
        let topCategories = getTopCategories()
        var categoryStrings: [String] = []
        
        for category in topCategories {
            if let todoEntry = toDoList.uuidToEntry(category.todoID) {
                categoryStrings.append(todoEntry.todo)
            }
        }
        
        return categoryStrings
    }
    
    func getDateHours() -> [Date: TimeInterval] {
        var acc: [Date: TimeInterval] = [:]
        for session in sessions {
            acc[Calendar.current.startOfDay(for: session.started), default: 0] += session.timeLocked
        }
        return acc
    }

    /// gets roasts, sorted in reverse chronological order
    func getLatestRoasts() -> [String] {
        let roasts = sessions.sorted{ $0.started > $1.started }.compactMap{ $0.roast }
        return roasts;
    }
}

class SessionsLoader {
    static var defaultSessions: Sessions = Sessions(sessions: []);

    static func loadSessions(onUpdate: @escaping (_: Sessions) -> Void) -> Sessions {
        let data = UserDefaults.standard.data(forKey: "user-sessions");
        if let liveData = data {
            if let decoded = try? JSONDecoder().decode(Sessions.self, from: liveData) {
                decoded.onUpdate = onUpdate;
                return decoded;
            }
            print("Incorrect Data Type");
            return defaultSessions;
        } else {
            saveSessions(defaultSessions);
            return defaultSessions;
        }
    }
    
    static func saveSessions(_ sessions: Sessions) {
        if let encoded = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(encoded, forKey: "user-sessions");
        }
    }
}
