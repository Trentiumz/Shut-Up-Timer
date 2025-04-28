import SwiftUI;

struct CountdownSelectorView : View{
    @Binding private var timerParams: TimerParam;
    
    @State private var timerType: TimerType;
    
    // countdown view params
    @State private var showingPicker = false;
    @State private var duration: TimeInterval = 0;
    
    init(timerParams: Binding<TimerParam>) {
        self._timerParams = timerParams;
        self._timerType = State(initialValue: timerParamToType(param: timerParams.wrappedValue));
    }
    
    func syncVarsToParams() {
        switch timerParams {
        case .countdown(let seconds):
            timerType = .countdown;
            duration = TimeInterval(seconds);
        }
    }
    
    func syncParamsToVars() {
        switch timerType {
        case .countdown:
            timerParams = .countdown(seconds: Int(duration.rounded()));
        }
    }
    
    var body : some View {
        VStack {
            switch timerType {
            case .countdown:
                // a rectangle allowing you to pick the amount of time
                Button (action: {
                    showingPicker = true;
                }) {
                    Text("\(formatTime(duration))")
                        .frame(width: 150, height: 150)
                        .padding()
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.orange)
                        .background(.gray)
                        .cornerRadius(10)
                }.sheet(isPresented: $showingPicker) {
                    DurationPickerModal(duration: $duration)
                }.onChange(of: duration) {
                    syncParamsToVars()
                }
            }
        }.onAppear(){
            syncVarsToParams()
        }.onChange(of: timerParams) {
            syncVarsToParams()
        }.onChange(of: timerType) {
            syncParamsToVars()
        }
    }
}
