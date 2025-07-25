import SwiftUI

struct TimerFailedView: View {
    @EnvironmentObject var router: AppRouter;
    private var session: TempSession
    
    init(session: TempSession) {
        self.session = session;
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Spacer()
                    .frame(minHeight: 470)
                
                if let roast = session.roast {
                    Text(roast)
                        .font(FontTokens.architectsDaughter(size: 35))
                        .foregroundColor(ColorTokens.shade700)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.5)
                        .frame(width: 350, alignment: .center)
                }
                
                Spacer()
                    .frame(maxHeight: 10)
                
                OnboardingNextButton(text: "Take a Picture", onSelect: {
                    router.toTimerCameraView(sessionID: session.id)
                })
                
                Spacer()
                    .frame(maxHeight: 20)
            }
            .cornerRadius(20)
            
            Text("You failed!")
                .font(FontTokens.architectsDaughter(size: 45))
                .foregroundColor(ColorTokens.shade700)
                .multilineTextAlignment(.center)
                .frame(width: 360, alignment: .center)
                .foregroundColor(ColorTokens.red300)
                .offset(y: -50)
        }.background(alignment: .top) {
            FormattedImages.MadMotherImage(0, width: 1200)
                .offset(x: -150, y: -500)
        }
    }
}

#Preview {
    TimerFailedView(session: TempSession(tasks: [], started: Date(), ended: Date(), timeLocked: 170, plannedTime: 170, success: false, roast: "You are a big potato and a bad idea :("))
}
