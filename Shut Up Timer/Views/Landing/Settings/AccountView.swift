import SwiftUI;

struct AccountView : View {
    // current settings
    @State private var curSettings: SettingsModel
    
    // the current type of element
    @State private var curType: TimerType
    
    init() {
        let curSettings = Settings.loadSettings()
        self.curSettings = curSettings;
        curType = timerParamToType(param: curSettings.timerParam);
    }
    
    var body: some View {
        VStack {
            // difficulty selector
            HStack {
                Text("Difficulty")
                Spacer()
                Picker("Difficulty", selection: $curSettings.difficulty) {
                    ForEach(Difficulty.allCases) { difficulty in
                        Text(difficulty.rawValue.capitalized).tag(difficulty)
                    }
                }
                .pickerStyle(.menu)
            }
            // roast level selector
            HStack {
                Text("Roast Level")
                Spacer()
                Picker("Difficulty", selection: $curSettings.roastLevel) {
                    ForEach(RoastLevel.allCases) { level in
                        Text(level.rawValue.capitalized).tag(level)
                    }
                }
                .pickerStyle(.menu)
            }
            
            TimerSelector(param: $curSettings.timerParam)
        }
        .padding()
        .onChange(of: curSettings) {
            Settings.saveSettings(settings: curSettings)
        }
    }
}

#Preview {
    AccountView();
}
