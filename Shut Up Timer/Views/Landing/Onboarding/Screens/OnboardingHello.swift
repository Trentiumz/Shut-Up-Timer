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
                ScrollView {
                    VStack(spacing: 0) {
                        if let onPrevious = self.onPrevious {
                            BackButton(onPress: onPrevious);
                        }
                        Spacer()
                        LinedPaper(text: infoText, iconAlignment: .topTrailing, imageHeight: 290)
                        Spacer()
                        
                        OnboardingNextButton(text: buttonText, onSelect: onPress)
                        Spacer()
                            .frame(maxHeight: 100)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: geo.size.height)
                }
                .frame(minHeight: geo.size.height)
            }
        }
        .background(ColorTokens.shade300)
    }
}

#Preview {
    OnboardingHello(infoText: "Testing text!", buttonText: "Hello", onPress: {print("Press!")}, onPrevious: {print("Previous")})
}
