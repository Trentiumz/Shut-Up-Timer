import SwiftUI

struct OnboardingV2Screen1: View {
    let transitionToNext: () -> Void
    @State private var textInput: String = ""
    @State private var showPopup: Bool = false
    @State private var isFocused: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack(spacing: 0) {
                    // Left side - Text
                    HStack {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("WHY you\nprocrastinating AGAIN?!\nLemme fix that.")
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
                    
                    // Right side - Character image
                    HStack {
                        Spacer()
                        Group {
                            Image(uiImage: FormattedImages.Image164)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: geometry.size.width, height: geometry.size.width)
                                .rotationEffect(Angle(degrees: -45))
                                .clipped()
                        }
                        .frame(width: geometry.size.width / 2, alignment: .leading)
                        .scaleEffect(isFocused ? 0.7 : 1.0)
                        .offset(x: isFocused ? geometry.size.width * 0.1 : 0)
                        .animation(.easeInOut(duration: 0.3), value: isFocused)
                    }
                    .layoutPriority(-1)
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
                            .redButton(title: "Spare me.", action: {
                                textInput = "Spare me."
                            }),
                            .redButton(title: "Yes, mother.", action: {
                                textInput = "Yes, mother."
                            }),
                            .sendButton(title: "Send", action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    showPopup = true
                                }
                            })
                        ]
                    )
                    .frame(maxWidth: .infinity)
                    .ignoresSafeArea(.container)
                }
                
                // Popup overlay
                if showPopup {
                    // Dimmed background
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .transition(.opacity)
                        .onTapGesture {
                            dismissPopupAndProceed()
                        }
                }
                    
                // Lined popup with animated entrance from the top
                VStack {
                    Spacer()
                    
                    if showPopup {
                        LinedPopup() {
                            VStack(alignment: .center, spacing: 8) {
                                Text("This app will roast you if you slack off and reward you if you actually work. Sound good?")
                                    .font(FontTokens.architectsDaughter(size: 20))
                                    .minimumScaleFactor(0.7)
                                    .padding(.top)
                                    .padding(.horizontal)
                                    .multilineTextAlignment(.leading)
                                    .foregroundStyle(ColorTokens.shade700)
                                OnboardingRedButton(title: "Sounds good", action: dismissPopupAndProceed, isFullWidth: false)
                                    .padding(.top)
                                    .padding(.trailing, 20)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .onTapGesture {
                            dismissPopupAndProceed()
                        }
                        .padding(.horizontal, 24)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .frame(height: geometry.size.height)
        }
    }
    
    private func dismissPopupAndProceed() {
        withAnimation(.easeInOut(duration: 0.2)) {
            showPopup = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
            transitionToNext()
        }
    }
}

#Preview {
    ZStack {
        Background()
        OnboardingV2Screen1(transitionToNext: {})
    }
}
