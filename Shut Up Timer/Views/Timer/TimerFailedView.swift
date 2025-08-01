import SwiftUI

// MARK: - Reusable Components

struct TimerResultBox: View {
    let mainText: String
    let subText: String
    let textColor: Color
    
    var body: some View {
        HStack {
            Text(mainText)
                .font(FontTokens.architectsDaughter(size: 36))
                .foregroundColor(textColor)
                .minimumScaleFactor(0.8)
                .lineLimit(1)
            Text(subText)
                .font(FontTokens.architectsDaughter(size: 18))
                .lineLimit(2)
                .foregroundColor(textColor)
                .minimumScaleFactor(0.5)
                .frame(maxHeight: .infinity)
        }
        .padding(.horizontal, 2)
        .frame(maxWidth: .infinity, alignment: .center)
        .frame(height: 70)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(ColorTokens.shade300)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.white, lineWidth: 2)
                )
        )
    }
}

struct TimerResultButton: View {
    let text: String
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            Text(text)
                .font(FontTokens.architectsDaughter(size: 24))
                .foregroundColor(.black)
                .padding(.vertical, 14)
                .padding(.horizontal, 36)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(ColorTokens.shade200)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(.white, lineWidth: 4)
                )
        }
    }
}

// MARK: - Main View

struct TimerFailedView: View {
    @EnvironmentObject var router: AppRouter;
    private var session: TempSession
    
    init(session: TempSession) {
        self.session = session;
    }
    
    var body: some View {
        ZStack {
            // Background
            Background()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Background overlay with red triangles
            GeometryReader { screen in
                TimerBackgroundOverlay(screen: screen)
            }
            .ignoresSafeArea(.all)
            
            // Main content area
            VStack(spacing: 0) {
                
                // Failure dialog box
                VStack(spacing: 0) {
                    Text("It's time for a picture...")
                        .font(FontTokens.architectsDaughter(size: 28))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    
                    Spacer()
                        .frame(maxHeight: 40)
                    
                    // Data display boxes
                    HStack(spacing: 15) {
                        // Left box - Study time
                        TimerResultBox(
                            mainText: formatStudyTime(),
                            subText: "of study",
                            textColor: ColorTokens.red300
                        )
                        
                        // Right box - IQ change
                        TimerResultBox(
                            mainText: formatIQChange(),
                            subText: "",
                            textColor: ColorTokens.red300
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 60)
                .padding(.top, 40)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(ColorTokens.gray800)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.white, lineWidth: 4)
                        )
                )
                .background(
                    Image(uiImage: FormattedImages.Image181)
                        .resizable()
                        .frame(width: 230, height: 300)
                        .offset(x: -60, y: -200)
                    ,
                    alignment: .topLeading
                )
                .overlay(
                    ZStack(alignment: .top) {
                        // Wavy red banner
                        Image(uiImage: FormattedImages.Image180)
                            .resizable()
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, -10)
                            .frame(height: 100)
                        
                        VStack(spacing: 0) {
                            Text("YOU'RE A...")
                                .font(FontTokens.architectsDaughter(size: 16))
                                .foregroundColor(.white)
                            
                            Text("FAILURE")
                                .font(FontTokens.architectsDaughter(size: 48))
                                .minimumScaleFactor(0.7)
                                .foregroundColor(.white)
                                .padding(.top, -15)
                        }
                        .frame(height: 60, alignment: .top)
                        .padding(.top, 15)
                    }.offset(y: -70),
                    alignment: .top
                )
                .overlay(
                    Image(uiImage: FormattedImages.Image160)
                        .resizable()
                        .frame(width: 160, height: 120)
                        .rotationEffect(Angle(degrees: -10))
                        .offset(x: 15, y: 40)
                    ,
                    alignment: .bottomTrailing
                )
                .padding(.horizontal, 20)
                .padding(.leading, 30)
            }
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    TimerResultButton(text: "Continue", onSelect: {
                        router.toTimerCameraView(sessionID: session.id)
                    })
                }
            }
            .padding()
        }
    }
    
    // Helper functions
    private func formatStudyTime() -> String {
        let hours = session.timeLocked / 3600
        return String(format: "%.1fhr", hours)
    }
    
    private func formatIQChange() -> String {
        let iqChange = session.iqChange
        if iqChange >= 0 {
            return "+\(String(format: "%.2f", iqChange))Q"
        } else {
            return "\(String(format: "%.2f", iqChange))Q"
        }
    }
}

#Preview {
    TimerFailedView(session: TempSession(
        tasks: [],
        started: Date(),
        ended: Date(),
        timeLocked: 19100, // ~5.3 hours
        plannedTime: 36000, // 10 hours planned
        success: false,
        roast: "You are a big potato and a bad idea :("
    ))
}
