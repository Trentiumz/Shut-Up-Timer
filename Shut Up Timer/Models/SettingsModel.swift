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

struct SettingsModel : Codable, Equatable {
    var firstTime: Bool;
    var difficulty: Difficulty;
    var roastLevel : RoastLevel;
    var timerParam : TimerParam;
}

class Settings {
    private static var defaultSettings: SettingsModel = SettingsModel(firstTime: true,
                                                                      difficulty: .easy,
                                                                      roastLevel: .low,
                                                                      timerParam: .countdown(seconds: 60 * 30));
    
    static func loadSettings() -> SettingsModel {
        let data = UserDefaults.standard.data(forKey: "user-settings");
        if let liveData = data {
            if let decoded = try? JSONDecoder().decode(SettingsModel.self, from: liveData) {
                return decoded;
            }
            print("Incorrect Data Type");
            return defaultSettings;
        } else {
            saveSettings(settings: defaultSettings);
            return defaultSettings;
        }
    }
    
    static func saveSettings(settings: SettingsModel) {
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: "user-settings")
        }
    }
    
    static func setFirstTime(val: Bool) {
        var curSettings = loadSettings();
        curSettings.firstTime = val;
        saveSettings(settings: curSettings);
    }
    
    static func setDifficulty(val: Difficulty) {
        var curSettings = loadSettings();
        curSettings.difficulty = val;
        saveSettings(settings: curSettings);
    }
    
    static func setRoastLevel(val: RoastLevel) {
        var curSettings = loadSettings();
        curSettings.roastLevel = val;
        saveSettings(settings: curSettings);
    }
    
    static func setTimerType(val: TimerParam) {
        var curSettings = loadSettings();
        curSettings.timerParam = val;
        saveSettings(settings: curSettings);
    }
}
