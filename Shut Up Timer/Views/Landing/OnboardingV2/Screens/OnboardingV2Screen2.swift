import SwiftUI

struct OnboardingV2Screen2: View {
    let transitionToNext: () -> Void
    @State private var textInput: String = ""
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack(spacing: 15) {
                    // Left side - Text
                    HStack {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Alright, slacker-\nwhat's ONE thing\nyou wanna get done?")
                                .font(FontTokens.architectsDaughter(size: 36))
                                .minimumScaleFactor(0.7)
                                .lineLimit(3)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                        }
                        .frame(maxWidth: .infinity)
                        Spacer()
                    }
                    
                    // Right side - Character image
                    HStack {
                        Spacer()
                        Image(uiImage: FormattedImages.Image164)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: geometry.size.width * 3 / 4)
                    }
                    Spacer()
                }
                
                VStack {
                    Spacer()
                    // Bottom action panel
                    OnboardingActionPanel(
                        textInput: $textInput,
                        instructionText: "Press send to proceed.",
                        actionButtons: [
                            .redButton(title: "Learn to code", action: {
                                textInput = "Learn to code"
                            }),
                            .redButton(title: "Finish my essay", action: {
                                textInput = "Finish my essay"
                            }),
                            .sendButton(action: {transitionToNext()})
                        ]
                    )
                    .frame(maxWidth: .infinity)
                    .ignoresSafeArea(.container)
                }
            }
            .frame(height: geometry.size.height)
        }
    }
}

#Preview {
    ZStack {
        Background()
        OnboardingV2Screen2(transitionToNext: {})
    }
}
