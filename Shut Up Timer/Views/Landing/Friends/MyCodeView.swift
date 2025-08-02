import SwiftUI

struct MyCodeView: View {
    let userProfile: UserProfileResponse?
    let errorMessage: String?
    let onSendRequest: (String) -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let profile = userProfile {
                    FriendQRInvite(
                        data: "shutuptimer://friend-invite?code=\(profile.friend_code)",
                        userProfile: profile
                    )
                } else {
                    Text("Login to add friends!")
                        .font(FontTokens.architectsDaughter(size: 20))
                        .foregroundColor(ColorTokens.shade100)
                }
            }
            .padding()
        }
    }
}

#Preview("With Profile Data") {
    MyCodeView(
        userProfile: UserProfileResponse(friend_code: "123456", is_public_profile_visible: true, sessions: []),
        errorMessage: nil,
        onSendRequest: { _ in }
    )
}
