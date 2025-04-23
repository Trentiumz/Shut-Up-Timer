import SwiftUI;

enum Difficulty : Codable {
    case easy;
    case medium;
    case asian;
}

enum RoastLevel : Codable {
    case low;
    case med;
    case high;
}

struct SettingsModel : Codable{
    var firstTime: Bool;
    var difficulty: Difficulty;
    var roastLevel : RoastLevel;
}

class Settings {
    private static var defaultSettings: SettingsModel = SettingsModel(firstTime: true, difficulty: .easy, roastLevel: .low);
    
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
}
