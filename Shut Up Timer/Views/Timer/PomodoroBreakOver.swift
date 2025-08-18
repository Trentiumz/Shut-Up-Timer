import SwiftUI

struct PomodoroBreakOver: View {
    let onContinue: () -> Void
    let onComplete: () -> Void

    private var breakOverBanner: some View {
        Image("BREAKOVER1")
            .resizable()
            .scaledToFit()
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
            .padding(.bottom, 4)
            .padding(.trailing, 30)
            .allowsHitTesting(false)
    }

    private var grandmaUIImage: UIImage {
        return FormattedImages.Image172
    }

    var body: some View {
        VStack(spacing: 0) {

            let paper = FormattedImages.Image134
            let aspect = paper.size.width / max(paper.size.height, 1)
            
            Image(uiImage: paper)
                .resizable()
                .scaledToFit()
                .rotationEffect(.degrees(2))
                .aspectRatio(aspect, contentMode: .fit)
                .overlay(
                    breakOverBanner
                        .padding(.top, -30)
                    ,
                    alignment: .top
                )
                .overlay(
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Your pomodoro break has been completed!")
                                .font(FontTokens.architectsDaughter(size: 20))
                                .foregroundStyle(ColorTokens.shade700)
                                .lineLimit(4)
                                .minimumScaleFactor(0.7)
                            
                            Text("Continue?")
                                .font(FontTokens.architectsDaughter(size: 20))
                                .foregroundStyle(ColorTokens.shade700)
                                .lineLimit(2)
                                .minimumScaleFactor(0.7)
                                .padding(.top, 6)
                        }
                        .padding(.vertical, 18)
                        .padding(.trailing, 20)
                        .padding(.leading, 48)
                        
                        VStack {
                            Spacer()
                            Group {
                                Image(uiImage: grandmaUIImage)
                                    .resizable()
                                    .scaledToFit()
                                    .padding(.trailing)
                                    .frame(width: 200)
                                    .allowsHitTesting(false)
                            }
                            .frame(width: 120, alignment: .leading)
                            .padding(.trailing, 8)
                        }
                    }
                )

            HStack(spacing: 16) {
                PopQuizPrimaryButton(title: "Hell Yes!", action: onContinue)
                PopQuizGrayButton(title: "I'm Done", action: onComplete)
            }
            .padding(.top, 12)
            .padding(.horizontal)
        }
    }
}

#Preview {
    ZStack {
        Color.black
        PomodoroBreakOver(onContinue: {}, onComplete: {})
            .padding()
    }
}
