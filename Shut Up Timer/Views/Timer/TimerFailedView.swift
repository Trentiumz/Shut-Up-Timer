import SwiftUI

struct TimerFailedView: View {
    @EnvironmentObject var router: AppRouter;
    private var session: SessionEntry
    
    init(session: SessionEntry) {
        self.session = session;
    }
    
    var body: some View {
        ZStack {
            FormattedImages.MadMotherImage(0, width: 1200)
                .offset(x: -150, y: -300)
            VStack {
                Spacer()
                    .frame(maxHeight: 600)
                
                if let roast = session.roast {
                    Text(roast)
                        .font(FontTokens.architectsDaughter(size: 35))
                        .foregroundColor(ColorTokens.shade700)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.5)
                        .frame(width: 360, alignment: .center)
                }
                
                OnboardingNextButton(text: "Take a Picture", onSelect: {
                    router.toTimerCameraView(sessionID: session.id)
                })
                
                Spacer()
                    .frame(maxHeight: 60)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity) // Full-screen view
            .cornerRadius(20)
            
            Text("You failed!")
                .font(FontTokens.architectsDaughter(size: 45))
                .foregroundColor(ColorTokens.shade700)
                .multilineTextAlignment(.center)
                .frame(width: 360, alignment: .center)
                .foregroundColor(ColorTokens.red300)
        }
    }
}

#Preview {
    TimerFailedView(session: SessionEntry(tasks: [], started: Date(), ended: Date(), timeLocked: 170, plannedTime: 170, success: false, roast: "You are a big potato and a bad idea :("))
}
