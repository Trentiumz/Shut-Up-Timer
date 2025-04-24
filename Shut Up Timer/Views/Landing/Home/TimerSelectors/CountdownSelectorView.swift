import SwiftUI;

struct CountdownSelectorView : View{
    @Binding private var timerParams: TimerType;
    @State private var duration: TimeInterval;
    @State private var showingPicker = false;
    
    init(initialDuation: TimeInterval, timerParams: Binding<TimerType>) {
        self._duration = State(initialValue: initialDuation);
        self._timerParams = timerParams;
    }
    
    var body : some View {
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
            timerParams = .countdown(seconds: Int(duration.rounded()));
        }
    }
}
