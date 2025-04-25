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
            timerParam = .countdown(seconds: Int(cdDuration.rounded()));
        }
    }
    
    var body : some View {
        VStack {
            // change timer type
            HStack {
                Text("Timer Type")
                Spacer()
                Picker("Difficulty", selection: $timerType) {
                    ForEach(TimerType.allCases) { type in
                        Text(type.rawValue.capitalized).tag(type)
                    }
                }
                .pickerStyle(.menu)
            }
            
            switch timerParam {
            case .countdown(let seconds):
                // selector for duration
                HStack {
                    Text("Duration")
                    Spacer()
                    Button (action: {
                        showCDPicker = true;
                    }) {
                        Text("\(formatTime(Double(seconds)))")
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


#Preview {
    PreviewContainer()
}

private struct PreviewContainer: View {
    @State private var timerParam: TimerParam = .countdown(seconds: 1200)

    var body: some View {
        TimerSelector(param: $timerParam);
    }
}
