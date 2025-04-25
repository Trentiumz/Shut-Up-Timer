import SwiftUI;

struct TimerSelector : View {
    @Binding var timerParam: TimerParam;
    
    @State private var timerType: TimerType;
    
    @State var showCDPicker: Bool = false;
    @State var cdDuration: TimeInterval = 0;
    
    init(param: Binding<TimerParam>) {
        self._timerParam = param;
        self._timerType = State(initialValue: timerParamToType(param: param.wrappedValue))
        switch param.wrappedValue {
        case .countdown(let seconds):
            self._cdDuration = State(initialValue: TimeInterval(seconds));
        }
    }
    
    var body : some View {
        HStack {
            Text("Timer Type")
            Spacer()
            Picker("Difficulty", selection: $timerType) {
                ForEach(TimerType.allCases) { type in
                    Text(type.rawValue.capitalized).tag(type)
                }
            }
            .pickerStyle(.menu)
        }.onChange(of: timerType) {
            switch timerType {
            case .countdown:
                if case .countdown = timerParam {
                } else {
                    timerParam = .countdown(seconds: 0);
                    cdDuration = TimeInterval(0);
                }
            }
        }
        
        switch timerParam {
        case .countdown(let seconds):
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
            }.onChange(of: cdDuration) {
                if case .countdown = timerParam {
                    timerParam = .countdown(seconds: Int(cdDuration.rounded()));
                }
            }
        }
    }
}


#Preview {
    PreviewContainer()
}

private struct PreviewContainer: View {
    @State private var timerParam: TimerParam = .countdown(seconds: 40)

    var body: some View {
        TimerSelector(param: $timerParam);
    }
}
