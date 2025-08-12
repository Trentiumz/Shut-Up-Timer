import SwiftUI

struct OnboardingTextInput: View {
    @Binding var text: String
    let placeholder: String
    let sendAction: () -> Void
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            TextField(placeholder, text: $text)
                .font(FontTokens.architectsDaughter(size: 20))
                .background(Color.white)
                .cornerRadius(8)
                .frame(maxWidth: .infinity)
                .focused($isFocused)
        }
        .onAppear {
            isFocused = true
        }
    }
}

#Preview {
    OnboardingTextInput(
        text: .constant(""),
        placeholder: "Type your message...",
        sendAction: {}
    )
    .padding()
    .background(Color("ColorlyShadeShade100"))
}
