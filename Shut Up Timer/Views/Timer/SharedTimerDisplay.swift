import SwiftUI

struct SharedTimerDisplay: View {
    let timerParam: TimerParam
    let namespace: Namespace.ID
    let isSource: Bool
    
    private var timeText: String {
        Utils.formatTime(timerParam.getDisplayTime())
    }
    
    private var subText: String {
        switch timerParam {
        case .countdown:
            return "LEFT"
        case .stopwatch:
            return "SPENT STUDYING"
        case .pomodoro(let pomo):
            switch(pomo.progress) {
            case .inSession:
                return "LEFT IN SESSION"
            case .onBreak:
                return "LEFT IN BREAK"
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            // Time display
            VStack(alignment: .trailing) {
                Text(timeText)
                    .font(FontTokens.architectsDaughter(size: 60))
                    .foregroundColor(.white)
                    .minimumScaleFactor(0.7)
                
                Text(subText)
                    .font(FontTokens.architectsDaughter(size: 18))
                    .foregroundColor(.white)
            }
            
            // Pan image
            ViewThatFits {
                Group {
                    Image(uiImage: FormattedImages.Image160)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 300, height: 230)
                }
                .frame(width: 300, height: 180, alignment: .bottom)
                
                Group {
                    Image(uiImage: FormattedImages.Image160)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 240, height: 180)
                }
                .frame(width: 270, height: 140, alignment: .bottom)
                
                Group {
                    Image(uiImage: FormattedImages.Image160)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 180, height: 140)
                }
                .frame(width: 240, height: 100, alignment: .bottom)
            }
        }
        .matchedGeometryEffect(id: "shared-timer-display", in: namespace, isSource: isSource)
    }
}

struct SharedTimerDisplayPreview: PreviewProvider {
    struct Wrapper: View {
        @Namespace var namespace
        
        var body: some View {
            ZStack {
                Background()
                SharedTimerDisplay(
                    timerParam: .countdown(seconds: 1920), // 32 minutes
                    namespace: namespace,
                    isSource: false
                )
            }
        }
    }
    
    static var previews: some View {
        Wrapper()
    }
} 
