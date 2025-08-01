import SwiftUI

struct ScanView: View {
    @State private var friendCodeInput = ""
    let errorMessage: String?
    let onSendRequest: (String) -> Void

    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        ZStack {
            // Background that can disable focus when tapped
            Color.clear
                .contentShape(Rectangle())
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onTapGesture {
                    withAnimation {
                        isTextFieldFocused = false
                    }
                }
            
            VStack(spacing: 20) {
                if isTextFieldFocused {
                    // Focused state - show keyboard input interface
                    VStack(spacing: 15) {
                        Text("Enter Friend Code")
                            .font(FontTokens.architectsDaughter(size: 24))
                            .foregroundColor(ColorTokens.shade100)
                    }
                    .padding()
                    .transition(.move(edge: .leading))
                } else {
                    // Normal scan view
                    VStack(spacing: 20) {
                        // QR Scanner (always active)
                        QRScanner(onScan: { code in
                            if let friendCode = extractFriendCode(from: code) {
                                withAnimation {
                                    friendCodeInput = friendCode
                                    isTextFieldFocused = true
                                }
                            }
                        })
                            .cornerRadius(12)
                            .padding(.vertical, 20)
                        
                        // Action buttons
                        VStack(spacing: 15) {
                            AlbumCodeSelector(onCodeUpdate: { qrCode in
                                if let friendCode = extractFriendCode(from: qrCode) {
                                    withAnimation {
                                        friendCodeInput = friendCode
                                        isTextFieldFocused = true
                                    }
                                }
                            }) {
                                Text("Scan from photos")
                                    .font(FontTokens.architectsDaughter(size: 18))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(ColorTokens.red300)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(ColorTokens.shade100, lineWidth: 2)
                                    )
                            }
                        }
                    }
                    .transition(.move(edge: .trailing))
                }
                
                HStack {
                    // Manual entry text field
                    TextField(
                        "",
                        text: $friendCodeInput,
                        prompt: Text("Enter Code Manually")
                            .font(FontTokens.architectsDaughter(size: 16))
                            .foregroundColor(ColorTokens.shade200)
                    )
                        .font(FontTokens.architectsDaughter(size: 16))
                        .foregroundColor(ColorTokens.shade100)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 6)
                        .background(Color.clear)
                        .focused($isTextFieldFocused)
                        .onTapGesture {
                            withAnimation {
                                isTextFieldFocused = true
                            }
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(ColorTokens.shade100, lineWidth: 2)
                        )
                    
                    if isTextFieldFocused {
                        Button("Send") {
                            withAnimation {
                                onSendRequest(friendCodeInput)
                                isTextFieldFocused = false
                            }
                        }
                        .font(FontTokens.architectsDaughter(size: 18))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(ColorTokens.red300)
                        .cornerRadius(8)
                        .transition(.move(edge: .trailing))
                    }
                }
                
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                Spacer()
            }
            .padding(.horizontal, 20)
        }
    }
    
    private func extractFriendCode(from qrCode: String) -> String? {
        // Extract friend code from QR code URL like "shutuptimer://friend-invite?code=123456789"
        if let url = URL(string: qrCode),
           let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let codeItem = components.queryItems?.first(where: { $0.name == "code" }) {
            return codeItem.value
        }
        return nil
    }
}

#Preview("Normal Scan View") {
    ZStack {
        Color.black
        ScanView(
            errorMessage: nil,
            onSendRequest: { _ in }
        )
    }
}
