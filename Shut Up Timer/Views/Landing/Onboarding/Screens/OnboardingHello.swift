import SwiftUI

struct OnboardingHello: View {
    let infoText: String
    let buttonText: String
    let onPress: () -> Void
    let onPrevious: (() -> Void)?
    
    var body: some View {
        ZStack {
            Background()
            GeometryReader { geo in
                VStack(spacing: 0) {
                    if let onPrevious = self.onPrevious {
                        BackButton(onPress: onPrevious);
                    }
                    Spacer()
                    LinedPaper(text: infoText, iconAlignment: .topTrailing, imageHeight: 290)
                    Spacer()
                    
                    VStack {
                        OnboardingNextButton(text: buttonText, onSelect: onPress)
                        Spacer()
                    }
                    .frame(height: geo.size.height / 4)
                }.frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(ColorTokens.shade300)
    }
}

#Preview {
    OnboardingHello(infoText: "Testing text!", buttonText: "Hello", onPress: {print("Press!")}, onPrevious: {print("Previous")})
}
