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
    
    func getTotTime() -> TimeInterval {
        return switch(self) {
        case .countdown(let seconds):
            seconds
        }
    }
}
enum TimerType: String, Codable, CaseIterable, Identifiable {
    case countdown;
    var id: String {self.rawValue }
}
func timerParamToType(param: TimerParam) -> TimerType {
    switch param {
    case .countdown:
        return .countdown;
    }
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
    @Published var timerParam: TimerParam {
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
    
    init(firstTime: Bool, firstTimerCompleted: Bool, dailyBeckon: Bool, difficulty: Difficulty, roastLevel: RoastLevel, timerParam: TimerParam, defaultBlockedApps: FamilyActivitySelection, appsToMonitor: FamilyActivitySelection) {
        self.firstTime = firstTime
        self.firstTimerCompleted = firstTimerCompleted
        self.dailyBeckon = dailyBeckon
        self.difficulty = difficulty
        self.roastLevel = roastLevel
        self.timerParam = timerParam
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
        l.timerParam == r.timerParam &&
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
        timerParam = try container.decode(TimerParam.self, forKey: .timerParam)
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
        try container.encode(timerParam, forKey: .timerParam)
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
                                                    timerParam: .countdown(seconds: 60 * 30),
                                                    defaultBlockedApps: FamilyActivitySelection(),
                                                    appsToMonitor: FamilyActivitySelection())
    static func loadSettings() -> Settings {
        let data = UserDefaults.standard.data(forKey: "user-settings")
        if let liveData = data {
            if let decoded = try? JSONDecoder().decode(Settings.self, from: liveData) {
                decoded.firstTime = false
                return decoded
            }
            print("Incorrect Data Type")
            return defaultSettings
        } else {
            saveSettings(defaultSettings)
            return defaultSettings
        }
    }
    
    static func saveSettings(_ settings: Settings) {
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: "user-settings")
        }
    }
}
