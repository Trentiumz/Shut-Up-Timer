import SwiftUI;

struct LandingTimerSelectorView: View {
    @EnvironmentObject var settings: Settings
    
    var body: some View {
        switch settings.timerType {
        case .countdown(let seconds):
            CountdownSelectorView(duration: Binding<TimeInterval>(
                get: {seconds},
                set: {settings.timerType = TimerType.countdown(seconds: $0)}
            ))
        case .stopwatch:
            StopwatchSelectorView()
        case .pomodoro(let sessionTime, let breakTime):
            PomodoroSelectorView(
                sessionTime: Binding<TimeInterval> (
                    get: {sessionTime},
                    set: {settings.timerType = .pomodoro(sessionTime: $0, breakTime: breakTime)}
                ), breakTime: Binding<TimeInterval> (
                    get: {breakTime},
                    set: {settings.timerType = .pomodoro(sessionTime: sessionTime, breakTime: $0)}
                ))
        }
    }
}

struct PomodoroSelectorView : View {
    @Binding var sessionTime: TimeInterval
    @Binding var breakTime: TimeInterval
    
    var body : some View {
        VStack(alignment: .trailing, spacing: 0) {
            // Time display - clickable to open picker
            VStack(alignment: .trailing, spacing: 0) {
                DurationPickerButton(val: $sessionTime) { time in
                    Text("Session: \(Utils.formatTime(time))")
                        .font(FontTokens.architectsDaughter(size: 32))
                        .foregroundStyle(.white)
                        .minimumScaleFactor(0.7)
                }
                DurationPickerButton(val: $breakTime) { time in
                    Text("Break: \(Utils.formatTime(time))")
                        .font(FontTokens.architectsDaughter(size: 24))
                        .foregroundStyle(.white)
                        .minimumScaleFactor(0.7)
                }
                Text("Pomodoro")
                    .font(FontTokens.architectsDaughter(size: 18))
                    .foregroundStyle(.white)
            }
            
            Spacer()
                .frame(maxHeight: 30)
            
            // Pan image
            ViewThatFits {
                Group {
                    Image(uiImage: FormattedImages.Image160)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 300, height: 230)
                }
                .frame(width: 300, height: 130, alignment: .bottom)
                
                Group {
                    Image(uiImage: FormattedImages.Image160)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 240, height: 180)
                }
                .frame(width: 270, height: 110, alignment: .bottomLeading)
                
                Group {
                    Image(uiImage: FormattedImages.Image160)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 180, height: 140)
                }
                .frame(width: 240, height: 80, alignment: .bottomLeading)
            }
        }
    }
}

struct StopwatchSelectorView : View{
    
    var body : some View {
        VStack(alignment: .trailing, spacing: 0) {
            // Time display - clickable to open picker
            VStack(spacing: 0) {
                Text("Stopwatch")
                    .font(FontTokens.architectsDaughter(size: 32))
                    .foregroundStyle(.white)
            }
            
            Spacer()
                .frame(maxHeight: 30)
            
            // Pan image
            ViewThatFits {
                Group {
                    Image(uiImage: FormattedImages.Image160)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 300, height: 230)
                }
                .frame(width: 300, height: 130, alignment: .bottom)
                
                Group {
                    Image(uiImage: FormattedImages.Image160)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 240, height: 180)
                }
                .frame(width: 270, height: 110, alignment: .bottomLeading)
                
                Group {
                    Image(uiImage: FormattedImages.Image160)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 180, height: 140)
                }
                .frame(width: 240, height: 80, alignment: .bottomLeading)
            }
        }
    }
}

struct CountdownSelectorView : View{
    @Binding private var duration: TimeInterval;
    
    // countdown view params
    @State private var showingPicker = false;
    
    init(duration: Binding<TimeInterval>) {
        self._duration = duration;
    }
    
    var body : some View {
        VStack(alignment: .trailing, spacing: 15) {
            // Time display - clickable to open picker
            Button(action: {
                showingPicker = true;
            }) {
                VStack(spacing: 0) {
                    Text("\(Utils.formatTime(duration))")
                        .font(FontTokens.architectsDaughter(size: 60))
                        .foregroundStyle(.white)
                        .minimumScaleFactor(0.7)
                    
                    Text("Countdown Timer")
                        .font(FontTokens.architectsDaughter(size: 18))
                        .foregroundStyle(.white)
                }
            }
            
            // Pan image
            ViewThatFits {
                Group {
                    Image(uiImage: FormattedImages.Image160)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 300, height: 230)
                }
                .frame(width: 300, height: 130, alignment: .bottom)
                
                Group {
                    Image(uiImage: FormattedImages.Image160)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 240, height: 180)
                }
                .frame(width: 270, height: 110, alignment: .bottomLeading)
                
                Group {
                    Image(uiImage: FormattedImages.Image160)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 180, height: 140)
                }
                .frame(width: 240, height: 80, alignment: .bottomLeading)
            }
        }
        .sheet(isPresented: $showingPicker) {
            DurationPickerModal(duration: $duration)
        }
    }
}

struct PanFrame : View {
    private var fi: Int;
    private var width: CGFloat;
    private var height: CGFloat;
    
    private var oWidth: CGFloat = 290;
    private var oHeight: CGFloat = 210;
    
    init(_ fi : Int, _ width: CGFloat, _ height: CGFloat? = nil) {
        assert(0 <= fi && fi < ImageAssets.panFryFrames.count);
        self.fi = fi;
        self.width = width;
        self.height = height ?? width / oWidth * oHeight;
    }
    
    var body : some View {
        Group {
            Rectangle()
              .foregroundColor(.clear)
              .frame(width: oWidth, height: oHeight)
              .background(
                ImageAssets.panFryFrames[fi]
                  .resizable()
                  .aspectRatio(contentMode: .fill)
                  .frame(width: 337, height: 311)
                  .clipped()
                  .offset(x: 10)
              )
        }
        .scaleEffect(min(width / oWidth, height / oHeight))
        .frame(width: width, height: height)
    }
}

struct CountdownSelectorPreview : PreviewProvider {
    struct Wrapper : View {
        @State var timerType: TimerType = .stopwatch;
        
        var body : some View {
            switch(timerType) {
                case .countdown(let seconds):
                ZStack {
                    Background()
                    CountdownSelectorView(duration: Binding<TimeInterval>(
                        get: {seconds},
                        set: {timerType = .countdown(seconds: $0)}
                    ))
                }
            case .stopwatch:
                ZStack {
                    Background()
                    StopwatchSelectorView()
                }
            case .pomodoro(let sessionTime, let breakTime):
                PomodoroSelectorView(
                    sessionTime: Binding<TimeInterval> (
                        get: {sessionTime},
                        set: {timerType = .pomodoro(sessionTime: $0, breakTime: breakTime)}
                    ), breakTime: Binding<TimeInterval> (
                        get: {breakTime},
                        set: {timerType = .pomodoro(sessionTime: sessionTime, breakTime: $0)}
                    ))
            }
        }
    }
    
    static var previews: some View {
        Wrapper()
    }
}
