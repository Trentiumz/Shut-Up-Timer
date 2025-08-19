import SwiftUI;

struct TimerSelector : View {
    // the timerParam that we're going to keep up to date
    @Binding var timerType: TimerType;
    
    init(param: Binding<TimerType>) {
        self._timerType = param
    }
    
    var body : some View {
        VStack {
            // change timer type
            HStack {
                SettingsView.SettingLabel("Timer Type")
                Spacer()
                Menu {
                    ForEach(TimerType.cases, id: \.0) { rep, onSelect in
                        SettingsView.StylizedOption(onClick: { timerType = onSelect}, text: rep)
                            .tag(rep)
                    }
                } label: {
                    SettingsView.StylizedLabel(timerType.description.capitalized)
                }
            }
            
            switch timerType {
            case .countdown(let seconds):
                // selector for duration
                HStack {
                    SettingsView.SettingLabel("Duration")
                    Spacer()
                    DurationPickerButton(val: Binding<TimeInterval>(
                        get: { seconds },
                        set: { timerType = .countdown(seconds: $0); }
                    ), label: { time in
                        SettingsView.StylizedLabel( "\(Utils.formatTime(time))")
                    })
                }
            case .stopwatch:
                EmptyView()
            case .pomodoro(let sessionTime, let breakTime):
                // TODO: fill in
                HStack {
                    SettingsView.SettingLabel("Session Time")
                    Spacer()
                    DurationPickerButton(val: Binding<TimeInterval>(
                        get: { sessionTime },
                        set: {
                            timerType = .pomodoro(sessionTime: $0, breakTime: breakTime)
                        }
                    ), label: { time in
                        SettingsView.StylizedLabel( "\(Utils.formatTime(time))")
                    })
                }
                HStack {
                    SettingsView.SettingLabel("Break Time")
                    Spacer()
                    DurationPickerButton(val: Binding<TimeInterval>(
                        get: { breakTime },
                        set: { timerType = .pomodoro(sessionTime: sessionTime, breakTime: $0) }
                    ), label: { time in
                        SettingsView.StylizedLabel( "\(Utils.formatTime(time))")
                    })
                }
            }
        }
    }
}

struct DurationPickerButton<Label: View>: View {
    @Binding var val: TimeInterval
    var label: (TimeInterval) -> Label
    @State private var showPicker: Bool = false
    
    var body: some View {
        Button (action: {
            showPicker = true;
        }) {
            label(val)
        }.sheet(isPresented: $showPicker) {
            DurationPickerModal(duration: $val)
        }
    }
}

struct TimerSelectorPreview : PreviewProvider {
    
    struct Wrapper : View {
        @State private var timerType: TimerType = .countdown(seconds: 1200)
        
        var body : some View {
            TimerSelector(param: $timerType)
            .environmentObject(AppRouter())
            .environmentObject(SettingsLoader.loadSettings())
            .environmentObject(CredManager(subscriptionManager: SubscriptionManager()))
        }
    }
    
    static var previews : some View {
        Wrapper()
    }
}
