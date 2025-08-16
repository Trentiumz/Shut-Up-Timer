import SwiftUI

// Screen 5: Pop quiz flow with intermediate states
// States: quiz -> failure (if wrong) -> math review -> quiz again -> passing -> subscription

struct OnboardingV2Screen5: View {
    let transitionToNext: () -> Void
    
    enum Step {
        case quiz
        case failure
        case mathReview
    }
    
    @State private var step: Step = .quiz
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 16) {
                Spacer()
                
                switch step {
                case .quiz:
                    quizCard
                case .failure:
                    failureCard
                case .mathReview:
                    MathReviewView(onRedo: {
                        withAnimation {
                            step = .quiz
                        }
                    })
                }
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.bottom, 12)
        }
    }
    
    // MARK: - Cards
    
    private var quizCard: some View {
        PopQuizCard(headerStyle: .popQuiz, content: {
            VStack(alignment: .leading, spacing: 10) {
                Text("Which has more value?")
                    .font(FontTokens.architectsDaughter(size: 24))
                    .foregroundStyle(ColorTokens.shade700)
                HStack(alignment: .top) {
                    Text("A. One boba\nB. 10X my focus")
                        .font(FontTokens.architectsDaughter(size: 24))
                        .lineLimit(3)
                        .minimumScaleFactor(0.7)
                        .foregroundStyle(ColorTokens.shade700)
                    Spacer()
                        .layoutPriority(-1)
                    Spacer()
                        .frame(maxWidth: 100)
                }
            }
        }, cardOverlay: {
            FormattedImages.PolaroidBG(innerContent: {
                Color.black
            }, width: 120)
            .rotationEffect(Angle(degrees: 6))
            .offset(x: -5, y: 10)
        }, leftButton: {
            PopQuizSecondaryButton(title: "A. One boba", subtitle: "(only lasting 10min)") {
                withAnimation {
                    step = .failure
                }
            }
        }, rightButton: {
            PopQuizPrimaryButton(title: "B. 10X my focus") {
                transitionToNext()
            }
        })
    }
    
    private var failureCard: some View {
        PopQuizCard(headerStyle: .failure, content: {
            HStack {
                Text("Wow. You'll drop $7 on a cup of tea but not on achieving your goals?")
                    .font(FontTokens.architectsDaughter(size: 24))
                    .minimumScaleFactor(0.7)
                    .lineLimit(4)
                    .foregroundStyle(ColorTokens.shade700)
                Spacer()
                    .layoutPriority(-1)
                Spacer()
                    .frame(maxWidth: 90)
            }
        }, cardOverlay: {
            FormattedImages.PolaroidBG(innerContent: {
                ZStack {
                    Color.black
                    Image(uiImage: FormattedImages.Image189)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                        .rotationEffect(Angle(degrees: 12))
                }
            }, width: 120)
            .rotationEffect(Angle(degrees: 6))
            .offset(x: -5, y: 10)
        }, leftButton: {
            PopQuizPrimaryButton(title: "Redo the quiz!") {
                withAnimation {
                    step = .quiz
                }
            }
        }, rightButton: {
            PopQuizSecondaryButton(title: "yeah.") {
                withAnimation {
                    step = .mathReview
                }
            }
        })
    }
}

#Preview {
    ZStack {
        Color.black
        OnboardingV2Screen5(transitionToNext: {})
    }
}
