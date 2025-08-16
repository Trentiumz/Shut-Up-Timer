import SwiftUI

struct OnboardingV2Screen3_5: View {
    let transitionToNext: () -> Void
    @State private var textInput: String = ""
    @State private var isFocused: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack(spacing: 15) {
                    // Left side - Text
                    HStack {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("What's one thing you can\ndo today without crying\nabout it?")
                                .font(FontTokens.architectsDaughter(size: 36))
                                .minimumScaleFactor(0.7)
                                .lineLimit(3)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                        }
                        .frame(maxWidth: .infinity)
                        Spacer()
                    }
                    .padding()
                    
                    // Right side - Character image (different pose)
                    HStack {
                        Spacer()
                        Image(uiImage: FormattedImages.Image172)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: geometry.size.width * 0.78)
                            .scaleEffect(isFocused ? 0.7 : 1.0)
                            .offset(x: isFocused ? geometry.size.width * 0.1 : 0)
                            .animation(.easeInOut(duration: 0.3), value: isFocused)
                    }
                    Spacer()
                }
                .frame(height: geometry.size.height)
                .ignoresSafeArea(.keyboard, edges: .bottom)
                .onTapGesture {
                    isFocused = false
                }
                
                VStack {
                    Spacer()
                    // Bottom action panel
                    OnboardingActionPanel(
                        textInput: $textInput,
                        isFocused: $isFocused,
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
