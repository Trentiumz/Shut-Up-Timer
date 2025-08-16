import SwiftUI

struct OnboardingTextInput: View {
    @Binding var text: String
    @Binding var isFocused: Bool
    let placeholder: String
    let sendAction: () -> Void
    @FocusState private var internalIsFocused: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            TextField(placeholder, text: $text)
                .font(FontTokens.architectsDaughter(size: 20))
                .background(Color.white)
                .cornerRadius(8)
                .frame(maxWidth: .infinity)
                .focused($internalIsFocused)
        }
        .onAppear {
            internalIsFocused = true
            isFocused = true
        }
        .onChange(of: internalIsFocused) { newValue in
            isFocused = newValue
        }
        .onChange(of: isFocused) { newValue in
            internalIsFocused = newValue
        }
    }
}

#Preview {
    OnboardingTextInput(
        text: .constant(""),
        isFocused: .constant(false),
        placeholder: "Type your message...",
        sendAction: {}
    )
    .padding()
    .background(Color("ColorlyShadeShade100"))
}
