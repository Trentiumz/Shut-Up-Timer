import SwiftUI;

struct TimerSelector : View {
    // the timerParam that we're going to keep up to date
    @Binding var timerParam: TimerParam;
    
    // the currently selected timer type
    @State private var timerType: TimerType;
    
    // if the timer type is CountDown...
    @State var showCDPicker: Bool = false;
    @State var cdDuration: TimeInterval = 0;
    
    init(param: Binding<TimerParam>) {
        // bindings for params & initial state!
        self._timerParam = param;
        self.timerType = timerParamToType(param: param.wrappedValue)
        
        syncParamToVars()
    }
    
    func syncParamToVars() {
        self.timerType = timerParamToType(param: timerParam)
        
        // specific initial values for each type of parameter
        switch timerParam {
        case .countdown(let seconds):
            self.cdDuration = TimeInterval(seconds);
        }
    }
    
    func syncVarsToParam() {
        // update params based on the timerParam
        switch timerType {
        case .countdown:
            if case .countdown = timerParam {
            } else {
                cdDuration = 0;
            }
            timerParam = .countdown(seconds: cdDuration.rounded());
        }
    }
    
    var body : some View {
        VStack {
            // change timer type
            HStack {
                SettingsView.SettingLabel("Timer Type")
                Spacer()
                Menu {
                    ForEach(TimerType.allCases) { type in
                        SettingsView.StylizedOption(onClick: { timerType = type}, text: type.rawValue.capitalized)
                            .tag(type)
                    }
                } label: {
                    SettingsView.StylizedLabel(timerType.rawValue.capitalized)
                }
            }
            
            switch timerParam {
            case .countdown(let seconds):
                // selector for duration
                HStack {
                    SettingsView.SettingLabel("Duration")
                    Spacer()
                    Button (action: {
                        showCDPicker = true;
                    }) {
                        SettingsView.StylizedLabel( "\(formatTime(Double(seconds)))")
                    }.sheet(isPresented: $showCDPicker) {
                        DurationPickerModal(duration: $cdDuration)
                    }
                }
            }
        }.onChange(of: timerParam) {
            syncParamToVars()
        }.onChange(of: timerType) {
            syncVarsToParam()
        }.onChange(of: cdDuration) {
            syncVarsToParam()
        }.onAppear() {
            syncParamToVars()
        }
    }
}

struct TimerSelectorPreview : PreviewProvider {
    
    struct Wrapper : View {
        @State private var timerParam: TimerParam = .countdown(seconds: 1200)
        
        var body : some View {
            TimerSelector(param: $timerParam)
            .environmentObject(AppRouter())
            .environmentObject(SettingsLoader.loadSettings(onUpdate: {_ in }))
            .environmentObject(SessionsLoader.loadSessions(onUpdate: {_ in }))
            .environmentObject(ToDoLoader.getToDo(onUpdate: { _ in }))
            .environmentObject(CredManager())
        }
    }
    
    static var previews : some View {
        Wrapper()
    }
}
