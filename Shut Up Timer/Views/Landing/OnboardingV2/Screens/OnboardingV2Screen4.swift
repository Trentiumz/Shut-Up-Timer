import SwiftUI

struct OnboardingV2Screen4: View {
    let transitionToNext: () -> Void

    var body: some View {
        Group {
            VStack(alignment: .leading, spacing: 10) {
                Text("It's time....")
                    .font(FontTokens.architectsDaughter(size: 28))
                    .foregroundColor(.white)
                
                Text("TO GRIND!")
                    .font(FontTokens.architectsDaughter(size: 48))
                    .foregroundColor(.white)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding(.horizontal, 24)
    }
}

#Preview {
    OnboardingV2Screen4(transitionToNext: {})
        .background(Color.black)
}
