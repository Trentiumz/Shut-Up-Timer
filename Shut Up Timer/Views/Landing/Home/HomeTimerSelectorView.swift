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
                VStack(spacing: 0) {
                    Text("\(formatTime(duration))")
                        .font(FontTokens.architectsDaughter(size: 60))
                        .foregroundStyle(.white)
                    
                    // panfry button!
                    Button (action: {
                        showingPicker = true;
                    }) {
                        
                        PanFrame(0, 240, 220)
                            .padding(.horizontal)
                            .foregroundStyle(.orange)
                            .background(
                                ImageAssets.panFryFrames[0]
                                    .resizable()
                                    .frame(width: 150, height: 150)
                            )
                            .frame(width: 240, height: 160, alignment: .bottom)
                    }.sheet(isPresented: $showingPicker) {
                        DurationPickerModal(duration: $duration)
                    }.onChange(of: duration) {
                        syncParamsToVars()
                    }
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
            ZStack {
                Background()
                CountdownSelectorView(timerParams: $timerParams)
                // PanFrame(0, 150, 150)
            }
        }
    }
    
    static var previews: some View {
        Wrapper()
    }
}
