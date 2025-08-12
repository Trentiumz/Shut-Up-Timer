import SwiftUI

// MARK: - Math Review card

struct MathReviewView: View {
    let onRedo: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Header banner
            ZStack(alignment: .top) {
                Image(uiImage: FormattedImages.Image180)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 84)
                    .padding(.horizontal, -12)
                    .offset(y: -8)
                    .allowsHitTesting(false)
                Text("Math Review")
                    .font(FontTokens.architectsDaughter(size: 28))
                    .foregroundStyle(.white)
                    .padding(.top, 8)
            }
            .padding(.bottom, -36)
            .zIndex(2)

            // First lined paper - Math section
            let paper1 = FormattedImages.Image134
            ZStack(alignment: .topLeading) {
                Image(uiImage: paper1)
                    .resizable()
                    .scaledToFit()
                    .rotationEffect(.degrees(2))

                // Math content
                VStack(alignment: .leading, spacing: 12) {
                    Text("Let's math this out:")
                        .font(FontTokens.architectsDaughter(size: 20))
                        .foregroundStyle(ColorTokens.shade700)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("A. One boba = $6.99 (gone in 10mins)")
                        Text("B. App = $6.99 (10x more productive)")
                    }
                    .font(FontTokens.architectsDaughter(size: 16))
                    .foregroundStyle(ColorTokens.shade700)
                }
                .padding(.vertical, 18)
                .padding(.trailing, 12)
                .padding(.leading, 48)
                .padding(.top, 24)
            }
            .padding(.bottom, -8)
            .padding(.top, -8)
            
            // Tape on top
            Image(uiImage: FormattedImages.Image141)
                .resizable()
                .scaledToFit()
                .frame(width: 90)
                .allowsHitTesting(false)
                .padding(.vertical, -10)
                .zIndex(2)
                .overlay(
                    Group {
                        FormattedImages.PolaroidBG(innerContent: {Color.black},
                                                   width: 120)
                        .rotationEffect(Angle(degrees: 12))
                    }
                        .frame(width: 0, alignment: .leading)
                        .offset(x: -15)
                    ,
                    alignment: .trailing
                )

            // Second lined paper - Bonus section
            let paper2 = FormattedImages.Image134
            ZStack(alignment: .leading) {
                Image(uiImage: paper2)
                    .resizable()
                    .scaledToFit()
                    .rotationEffect(.degrees(2))

                // Bonus content
                VStack(alignment: .leading, spacing: 8) {
                    Text("[BONUS]")
                        .font(FontTokens.architectsDaughter(size: 20))
                        .foregroundStyle(ColorTokens.shade700)

                    Text("App contains:")
                        .font(FontTokens.architectsDaughter(size: 16))

                    VStack(alignment: .leading, spacing: 6) {
                        Text("- Brutal customized roasts")
                        Text("- IQ points (for bragging rights)")
                        Text("- Wall of Disappointment")
                        Text("- Progress tracking")
                    }
                    .font(FontTokens.architectsDaughter(size: 16))
                    .foregroundStyle(ColorTokens.shade700)
                }
                .padding(.vertical, 18)
                .padding(.trailing, 12)
                .padding(.leading, 48)
            }
            .padding(.top, -8)

            // Redo button using primary style
            PopQuizPrimaryButton(title: "Redo the quiz!", action: onRedo)
                .padding(.top, 8)
        }
    }
}

#Preview {
    ZStack {
        Color.black
        MathReviewView(onRedo: {})
            .padding()
    }
}


