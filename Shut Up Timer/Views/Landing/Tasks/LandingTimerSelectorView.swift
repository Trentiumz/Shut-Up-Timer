import SwiftUI;

struct LandingTimerSelectorView: View {
    @EnvironmentObject var settings: Settings
    
    var body: some View {
        switch settings.timerParam {
        case .countdown(let seconds):
            CountdownSelectorView(duration: Binding<TimeInterval>(
                get: {seconds},
                set: {settings.timerParam = TimerParam.countdown(seconds: $0)}
            ))
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
        @State var timerParams: TimerParam = .countdown(seconds: 20);
        
        var body : some View {
            switch(timerParams) {
                case .countdown(let seconds):
                ZStack {
                    Background()
                    CountdownSelectorView(duration: Binding<TimeInterval>(
                        get: {seconds},
                        set: {timerParams = .countdown(seconds: $0)}
                    ))
                }
            }
        }
    }
    
    static var previews: some View {
        Wrapper()
    }
}
