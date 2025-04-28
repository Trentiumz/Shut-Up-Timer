import SwiftUI;

struct AccountView : View {
    // current settings
    @EnvironmentObject var settings: Settings;
    
    init() {
    }
    
    var body: some View {
        VStack {
            // difficulty selector
            HStack {
                Text("Difficulty")
                Spacer()
                Picker("Difficulty", selection: $settings.difficulty) {
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
                Picker("Difficulty", selection: $settings.roastLevel) {
                    ForEach(RoastLevel.allCases) { level in
                        Text(level.rawValue.capitalized).tag(level)
                    }
                }
                .pickerStyle(.menu)
            }
            
            TimerSelector(param: $settings.timerParam)
        }
        .padding()
    }
}

#Preview {
    AccountView();
}
