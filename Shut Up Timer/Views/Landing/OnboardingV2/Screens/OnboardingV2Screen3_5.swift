import SwiftUI

struct OnboardingV2Screen3_5: View {
    let transitionToNext: () -> Void
    @State private var textInput: String = ""
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack(spacing: 15) {
                    // Left side - Text
                    HStack {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("What’s one thing you can\ndo today without crying\nabout it?")
                                .font(FontTokens.architectsDaughter(size: 36))
                                .minimumScaleFactor(0.7)
                                .lineLimit(3)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                        }
                        .frame(maxWidth: .infinity)
                        Spacer()
                    }
                    
                    // Right side - Character image (different pose)
                    HStack {
                        Spacer()
                        Image(uiImage: FormattedImages.Image172)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: geometry.size.width * 0.78)
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
                            .redButton(title: "Finish Chp 1", action: {
                                textInput = "Finish Chp 1"
                            }),
                            .redButton(title: "Finish research", action: {
                                textInput = "Finish research"
                            }),
                            .sendButton(action: { transitionToNext() })
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
        OnboardingV2Screen3_5(transitionToNext: {})
    }
}
