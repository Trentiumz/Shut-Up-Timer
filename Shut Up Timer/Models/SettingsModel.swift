import SwiftUI;

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
    case countdown (seconds: Int);
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

class Settings : Codable, Equatable, ObservableObject {
    @Published var firstTime: Bool{
        didSet {
            self.onUpdate(self);
        }
    }
    @Published var difficulty: Difficulty{
        didSet {
            self.onUpdate(self);
        }
    }
    @Published var roastLevel : RoastLevel{
        didSet {
            self.onUpdate(self);
        }
    }
    @Published var timerParam : TimerParam{
        didSet {
            self.onUpdate(self);
        }
    }
    var onUpdate: (_: Settings) -> Void = { _ in };
    
    init(firstTime: Bool, difficulty: Difficulty, roastLevel: RoastLevel, timerParam: TimerParam, onUpdate: @escaping (_: Settings) -> Void = { _ in }) {
        self.firstTime = firstTime;
        self.difficulty = difficulty
        self.roastLevel = roastLevel
        self.timerParam = timerParam
        self.onUpdate = onUpdate;
    }
    
    static func == (l: Settings, r: Settings) -> Bool {
        return l.firstTime == r.firstTime &&
        l.difficulty == r.difficulty &&
        l.roastLevel == r.roastLevel &&
        l.timerParam == r.timerParam;
    }
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case firstTime
        case difficulty
        case roastLevel
        case timerParam
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        firstTime = try container.decode(Bool.self, forKey: .firstTime)
        difficulty = try container.decode(Difficulty.self, forKey: .difficulty)
        roastLevel = try container.decode(RoastLevel.self, forKey: .roastLevel)
        timerParam = try container.decode(TimerParam.self, forKey: .timerParam)
        onUpdate = { _ in }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(firstTime, forKey: .firstTime)
        try container.encode(difficulty, forKey: .difficulty)
        try container.encode(roastLevel, forKey: .roastLevel)
        try container.encode(timerParam, forKey: .timerParam)
    }
}

class SettingsLoader {
    static var defaultSettings: Settings = Settings(firstTime: true,
                                                    difficulty: .easy,
                                                    roastLevel: .low,
                                                    timerParam: .countdown(seconds: 60 * 30));
    static func loadSettings(onUpdate: @escaping (_: Settings) -> Void = {_ in}) -> Settings {
        let data = UserDefaults.standard.data(forKey: "user-settings");
        if let liveData = data {
            if let decoded = try? JSONDecoder().decode(Settings.self, from: liveData) {
                decoded.onUpdate = onUpdate;
                return decoded;
            }
            print("Incorrect Data Type");
            return defaultSettings;
        } else {
            saveSettings(defaultSettings);
            return defaultSettings;
        }
    }
    
    static func saveSettings(_ settings: Settings) {
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: "user-settings")
        }
    }
}
