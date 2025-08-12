import SwiftUI

/// Onboarding screen that showcases a light-weight calendar and a numeric keypad
/// to capture the number of weeks needed. It mirrors the provided mock and is
/// responsive via `GeometryReader` and `ViewThatFits`.
struct OnboardingV2Screen3: View {
    let transitionToNext: () -> Void
    
    private enum LocalStage { case screen1, screen2 }
    @State private var localStage: LocalStage = .screen1
    
    @State private var weeksNeeded: Double = 0
    @State private var hoursPerWeek: Double = 0
    @State private var showPopup: Bool = false
    @State private var showPopupBot: Bool = false
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                VStack(spacing: 16) {
                    // Top content varies by local stage
                    ZStack(alignment: .bottom) {
                        Group {
                            // Only today's red highlight
                            let today = startOfDay(Date())
                            let hoursMap = [today: 12.0 * 3600.0]
                            PureCalendar(dayHours: hoursMap, currentDate: today, showBackgroundForZeroHours: false)
                        }
                        .padding(.horizontal, 20)
                        .opacity(localStage == .screen1 ? 1 : 0)
                        .allowsHitTesting(localStage == .screen1)
                        
                        // Character + instructional text
                        HStack(alignment: .top, spacing: 16) {
                            VStack {
                                Spacer()
                                    .frame(maxHeight: 80)
                                Group {
                                    Image(uiImage: FormattedImages.Image181)
                                        .resizable()
                                        .scaledToFit()
                                        .rotationEffect(Angle(degrees: 20))
                                        .frame(width: proxy.size.width * 0.6, height: proxy.size.width * 0.6)
                                }
                                .frame(width: proxy.size.width * 0.2, height: proxy.size.width * 0.4, alignment: .topLeading)
                            }
                            
                            Text("This turns into IQ points. Yes, you'll need them.")
                                .font(FontTokens.architectsDaughter(size: 22))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.trailing)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        .opacity(localStage == .screen2 ? 1 : 0)
                        .allowsHitTesting(localStage == .screen2)
                    }
                    
                    // Bottom: shared calculator card reusing CalculatorComponent
                    DarkContentContainer {
                        VStack(spacing: 0) {
                            Spacer(minLength: 8)
                            if localStage == .screen1 {
                                CalculatorComponent(
                                    value: $weeksNeeded,
                                    placeholder: "How many weeks do you need to accomplish this goal?",
                                    onEnter: {
                                        withAnimation(.easeInOut(duration: 0.25)) {
                                            localStage = .screen2
                                        }
                                    }
                                )
                            } else {
                                CalculatorComponent(
                                    value: $hoursPerWeek,
                                    placeholder: "How many hrs would you spend on this for a week?",
                                    onEnter: {
                                        presentFirstPopup()
                                    }
                                )
                            }
                            Spacer(minLength: 8)
                        }
                        .padding(16)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 20)
                }
                .frame(width: proxy.size.width, height: proxy.size.height)
                
                if showPopup {
                    Color.black.opacity(0.6)
                        .ignoresSafeArea()
                        .transition(.opacity)
                }
                
                if showPopup {
                    VStack {
                        Spacer()
                        popupContent(iqGoal: weeksNeeded * hoursPerWeek, advanceAction: handleSecondPopupAdvance, disabled: showPopupBot)
                            .padding(.horizontal, 24)
                            .transition(popupTransition)
                        Spacer()
                        if showPopupBot {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Reality check:")
                                        .font(FontTokens.architectsDaughter(size: 24))
                                        .foregroundColor(.white)
                                        .minimumScaleFactor(0.7)
                                        .lineLimit(1)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    Text("That goal's too big!")
                                        .font(FontTokens.architectsDaughter(size: 24))
                                        .foregroundColor(.white)
                                        .minimumScaleFactor(0.7)
                                        .lineLimit(1)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    Text("Task-ify it!")
                                        .font(FontTokens.architectsDaughter(size: 24))
                                        .foregroundColor(.white)
                                        .minimumScaleFactor(0.7)
                                        .lineLimit(1)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .padding(.horizontal, 16)
                                
                                Spacer()
                                    .layoutPriority(-1)
                                
                                Group {
                                    Image(uiImage: FormattedImages.Image166)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: min(220, proxy.size.width * 0.55))
                                        .rotationEffect(Angle(degrees: -15))
                                }
                                .frame(width: proxy.size.width * 0.3, alignment: .leading)
                                .edgesIgnoringSafeArea([.bottom, .trailing])
                                .padding(.top, 30)
                            }
                            .frame(maxWidth: .infinity)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Popup helpers
private extension OnboardingV2Screen3 {
    var popupTransition: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        )
    }
    
    @ViewBuilder
    func popupContent(iqGoal: Double, advanceAction: @escaping () -> Void, disabled: Bool) -> some View {
        LinedPopup() {
            VStack(alignment: .center, spacing: 10) {
                Text(String(format: "Your Goal = %.2f IQ pts", iqGoal))
                    .font(FontTokens.architectsDaughter(size: 22))
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.7)
                    .padding(.top)
                    .padding(.horizontal)
                    .foregroundStyle(ColorTokens.shade700)
                
                Text("The more you study the more IQ pts you get to redeem your goal.")
                    .font(FontTokens.architectsDaughter(size: 16))
                    .minimumScaleFactor(0.7)
                    .padding(.horizontal)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(ColorTokens.shade700)
                
                OnboardingRedButton(title: "Rescue my IQ!", action: advanceAction, isFullWidth: true)
                    .padding(.top)
                    .padding(.horizontal, 20)
                    .disabled(disabled)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    func presentFirstPopup() {
        withAnimation(.easeInOut(duration: 0.25)) { showPopup = true }
    }
    
    func handleSecondPopupAdvance() {
        withAnimation(.easeInOut(duration: 0.25)) { showPopupBot = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation(.easeInOut(duration: 0.25)) { showPopup = false; showPopupBot = false }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.26) {
                transitionToNext()
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black
        OnboardingV2Screen3(transitionToNext: {})
            .padding()
    }
}
