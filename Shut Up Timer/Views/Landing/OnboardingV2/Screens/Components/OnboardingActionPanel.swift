import SwiftUI

struct OnboardingActionPanel: View {
    @Binding var textInput: String
    let instructionText: String
    let actionButtons: [OnboardingActionButton]
    
    enum OnboardingActionButton {
        case redButton(title: String, action: () -> Void)
        case sendButton(title: String? = nil, action: () -> Void)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Top: Text input with integrated Send button
            OnboardingTextInput(
                text: $textInput,
                placeholder: instructionText,
                sendAction: {
                    // Find the send button action
                    if let sendButton = actionButtons.first(where: { 
                        if case .sendButton = $0 { return true }
                        return false
                    }) {
                        if case .sendButton(_, let action) = sendButton {
                            action()
                        }
                    }
                }
            )
            .padding(.horizontal, 8)
            .padding(.top, 8)
            
            // Row: red buttons (equal width)
            HStack(spacing: 12) {
                ForEach(Array(actionButtons.enumerated()), id: \.offset) { _, button in
                    switch button {
                    case .redButton(let title, let action):
                        OnboardingRedButton(title: title, action: action)
                    case .sendButton(let title, let action):
                        OnboardingSendButton(title: title ?? "Send", action: action)
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .background(ColorTokens.shade100)
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var textInput = ""
        
        var body: some View {
            OnboardingActionPanel(
                textInput: $textInput,
                instructionText: "Press send to proceed.",
                actionButtons: [
                    .redButton(title: "Spare me.", action: {
                        print("Spare me tapped")
                    }),
                    .redButton(title: "Yes, mother.", action: {
                        print("Yes, mother tapped")
                    }),
                    .sendButton(title: "Send", action: {
                        print("Send tapped with text: \(textInput)")
                    })
                ]
            )
            .padding()
            .background(Color.gray.opacity(0.1))
        }
    }
    
    return PreviewWrapper()
}
