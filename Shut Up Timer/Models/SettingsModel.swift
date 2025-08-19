import SwiftUI
import Combine
import FamilyControls

enum TimerManagerType: String, Codable, CaseIterable, Identifiable {
    case noLeave
    case appBlock
    
    var id: String { self.rawValue }
}

enum Difficulty : String, Codable, CaseIterable, Identifiable {
    case easy;
    case medium;
    case asian;
    var id: String { self.rawValue }
}

enum RoastLevel : String, Codable, CaseIterable, Identifiable {
    case low;
    case med;
    case high;
    
    var id: String { self.rawValue }
}

enum TimerParam : Codable, Equatable {
    case countdown (seconds: TimeInterval);
    case stopwatch (time: TimeInterval)
    case pomodoro (pomo: Pomodoro)
    
    static func from(_ from: TimerType) -> TimerParam {
        switch(from) {
        case .countdown(let seconds):
                .countdown(seconds: seconds)
        case .stopwatch:
                .stopwatch(time: 0)
        case .pomodoro(let sessionTime, let breakTime):
                .pomodoro(pomo: Pomodoro(progress: .inSession(left: sessionTime), timeLocked: 0, sessionTime: sessionTime, breakTime: breakTime))
        }
    }
    
    struct Pomodoro : Codable, Equatable {
        enum Progress : Codable, Equatable {
            case inSession(left: TimeInterval)
            case onBreak(left: TimeInterval)
        }
        let progress: Progress
        let timeLocked: TimeInterval
        let sessionTime: TimeInterval
        let breakTime: TimeInterval
    }
    
    func getDisplayTime() -> TimeInterval {
        return switch(self) {
        case .countdown(let seconds):
            seconds
        case .stopwatch(let time):
            time
        case .pomodoro(let pomo):
            switch(pomo.progress) {
            case .inSession(let left):
                left
            case .onBreak(let left):
                left
            }
        }
    }
    
    /// the total time REQUIRED in the session (smaller means more time locked in)
    func getTimeRemaining() -> TimeInterval {
        return switch(self) {
        case .countdown(let seconds):
            seconds
        case .stopwatch(let time):
            -time
        case .pomodoro(let pomo):
            -pomo.timeLocked
        }
    }
    
    func update(timeSince: TimeInterval) -> TimerParam {
        return switch(self) {
        case .countdown(let seconds):
                .countdown(seconds: seconds - timeSince);
        case .stopwatch(let time):
                .stopwatch(time: time + timeSince);
        case .pomodoro(let pomo):
            switch(pomo.progress) {
            case .inSession(let left):
                    .pomodoro(pomo: Pomodoro(progress: .inSession(left: left - timeSince), timeLocked: pomo.timeLocked + timeSince, sessionTime: pomo.sessionTime, breakTime: pomo.breakTime))
            case .onBreak(let left):
                    .pomodoro(pomo: Pomodoro(progress: .onBreak(left: left - timeSince), timeLocked: pomo.timeLocked, sessionTime: pomo.sessionTime, breakTime: pomo.breakTime))
            }
        }
    }
}
enum TimerType: CustomStringConvertible, Codable, Equatable {
    case countdown(seconds: TimeInterval);
    case stopwatch;
    case pomodoro(sessionTime: TimeInterval, breakTime: TimeInterval);
    
    var description: String {
        return switch self {
        case .countdown(_):
            "Countdown"
        case .stopwatch:
            "Stopwatch"
        case .pomodoro(_, _):
            "Pomodoro"
        }
    }
    
    static let cases: [(String, TimerType)] = [
        ("Countdown", .countdown(seconds: 3600)),
        ("Stopwatch", .stopwatch),
        ("Pomodoro", .pomodoro(sessionTime: 1800, breakTime: 300))
    ]
}

class Settings: ObservableObject, Codable, Equatable {
    @Published var firstTime: Bool {
        didSet {
            didChange.send(self)
        }
    }
    @Published var firstTimerCompleted: Bool {
        didSet {
            didChange.send(self)
        }
    }
    @Published var dailyBeckon: Bool {
        didSet {
            didChange.send(self)
        }
    }
    @Published var difficulty: Difficulty {
        didSet {
            didChange.send(self)
        }
    }
    @Published var roastLevel: RoastLevel {
        didSet {
            didChange.send(self)
        }
    }
    @Published var timerType: TimerType {
        didSet {
            didChange.send(self)
        }
    }
    @Published var defaultBlockedApps: FamilyActivitySelection {
        didSet {
            didChange.send(self)
        }
    }
    @Published var appsToMonitor: FamilyActivitySelection {
        didSet {
            didChange.send(self)
        }
    }
    let didChange = PassthroughSubject<Settings, Never>()
    var cancellables = Set<AnyCancellable>()
    
    init(firstTime: Bool, firstTimerCompleted: Bool, dailyBeckon: Bool, difficulty: Difficulty, roastLevel: RoastLevel, timerType: TimerType, defaultBlockedApps: FamilyActivitySelection, appsToMonitor: FamilyActivitySelection) {
        self.firstTime = firstTime
        self.firstTimerCompleted = firstTimerCompleted
        self.dailyBeckon = dailyBeckon
        self.difficulty = difficulty
        self.roastLevel = roastLevel
        self.timerType = timerType
        self.defaultBlockedApps = defaultBlockedApps
        self.appsToMonitor = appsToMonitor
    }
    
    deinit {
        cancellables.removeAll()
    }
    
    static func == (l: Settings, r: Settings) -> Bool {
        return l.firstTime == r.firstTime &&
        l.firstTimerCompleted == r.firstTimerCompleted &&
        l.dailyBeckon == r.dailyBeckon &&
        l.difficulty == r.difficulty &&
        l.roastLevel == r.roastLevel &&
        l.timerType == r.timerType &&
        l.defaultBlockedApps.applicationTokens == r.defaultBlockedApps.applicationTokens &&
        l.defaultBlockedApps.categoryTokens == r.defaultBlockedApps.categoryTokens
    }
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case firstTime
        case firstTimerCompleted
        case dailyBeckon
        case difficulty
        case roastLevel
        case timerParam
        case defaultBlockedApps
        case appsToMonitor
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        firstTime = try container.decode(Bool.self, forKey: .firstTime)
        firstTimerCompleted = try container.decodeIfPresent(Bool.self, forKey: .firstTimerCompleted) ?? false
        dailyBeckon = try container.decodeIfPresent(Bool.self, forKey: .dailyBeckon) ?? false
        difficulty = try container.decode(Difficulty.self, forKey: .difficulty)
        roastLevel = try container.decode(RoastLevel.self, forKey: .roastLevel)
        timerType = try container.decode(TimerType.self, forKey: .timerParam)
        defaultBlockedApps = try container.decodeIfPresent(FamilyActivitySelection.self, forKey: .defaultBlockedApps) ?? FamilyActivitySelection()
        appsToMonitor = try container.decodeIfPresent(FamilyActivitySelection.self, forKey: .appsToMonitor) ?? FamilyActivitySelection()
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(firstTime, forKey: .firstTime)
        try container.encode(firstTimerCompleted, forKey: .firstTimerCompleted)
        try container.encode(dailyBeckon, forKey: .dailyBeckon)
        try container.encode(difficulty, forKey: .difficulty)
        try container.encode(roastLevel, forKey: .roastLevel)
        try container.encode(timerType, forKey: .timerParam)
        try container.encode(defaultBlockedApps, forKey: .defaultBlockedApps)
        try container.encode(appsToMonitor, forKey: .appsToMonitor)
    }
}

class SettingsLoader {
    static var defaultSettings: Settings = Settings(firstTime: true,
                                                    firstTimerCompleted: false,
                                                    dailyBeckon: true,
                                                    difficulty: .easy,
                                                    roastLevel: .low,
                                                    timerType: .countdown(seconds: 60 * 30),
                                                    defaultBlockedApps: FamilyActivitySelection(),
                                                    appsToMonitor: FamilyActivitySelection())
    static var sharedSettings: Settings? = nil
    
    static func loadSettings() -> Settings {
        if let sharedSettings = sharedSettings {
            return sharedSettings
        } else {
            let data = UserDefaults.standard.data(forKey: "user-settings")
            if let liveData = data {
                if let decoded = try? JSONDecoder().decode(Settings.self, from: liveData) {
                    decoded.firstTime = false
                    sharedSettings = decoded
                    return decoded
                }
                print("Incorrect Data Type")
                sharedSettings = defaultSettings
                return defaultSettings
            } else {
                saveSettings(defaultSettings)
                sharedSettings = defaultSettings
                return defaultSettings
            }
        }
    }
    
    static func saveSettings(_ settings: Settings) {
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: "user-settings")
        }
    }
}
