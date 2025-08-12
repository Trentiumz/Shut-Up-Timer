import SwiftUI

struct OnboardingButton: View {
    let title: String
    let backgroundColor: Color
    let textColor: Color
    let action: () -> Void
    let isFullWidth: Bool
    let cornerRadius: CGFloat
    let borderColor: Color
    let borderWidth: CGFloat
    
    init(
        title: String,
        backgroundColor: Color = Color("ColorlyRedRed300"),
        textColor: Color = .white,
        isFullWidth: Bool = true,
        cornerRadius: CGFloat = 10,
        borderColor: Color = .black,
        borderWidth: CGFloat = 1.5,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.action = action
        self.isFullWidth = isFullWidth
        self.cornerRadius = cornerRadius
        self.borderColor = borderColor
        self.borderWidth = borderWidth
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(FontTokens.architectsDaughter(size: 16))
                .minimumScaleFactor(0.7)
                .lineLimit(1)
                .foregroundColor(textColor)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .frame(maxWidth: isFullWidth ? .infinity : nil)
                .background(backgroundColor)
                .cornerRadius(cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(borderColor, lineWidth: borderWidth)
                )
        }
    }
}

struct OnboardingRedButton: View {
    let title: String
    let action: () -> Void
    var isFullWidth: Bool = true
    
    var body: some View {
        OnboardingButton(
            title: title,
            backgroundColor: Color("ColorlyRedRed300"),
            textColor: .white,
            isFullWidth: isFullWidth,
            action: action
        )
    }
}

struct OnboardingSendButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        OnboardingButton(
            title: title,
            backgroundColor: .white,
            textColor: Color("Gray800"),
            isFullWidth: false,
            action: action
        )
    }
}

#Preview {
    VStack(spacing: 12) {
        HStack(alignment: .top, spacing: 12) {
            OnboardingRedButton(title: "Spare me.", action: {})
            OnboardingRedButton(title: "Yes, mother.", action: {})
            OnboardingSendButton(title: "Send", action: {})
        }
    }
    .padding()
    .background(Color("ColorlyShadeShade100"))
}
