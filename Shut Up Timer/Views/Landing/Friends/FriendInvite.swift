import SwiftUI;

/// A view that handles friend-related functionality including:
/// - Displaying incoming friend requests
/// - Showing the user's friend code
/// - Allowing users to send friend requests to others
struct FriendInvite : View {
    @EnvironmentObject var credManager: CredManager;
    @EnvironmentObject var router: AppRouter;
    @State private var userProfile: UserProfileResponse? = nil;
    @State private var errorMessage: String? = nil;
    @State private var requestListRefreshTrigger = UUID();
    
    /// Fetches the user's profile information including their friend code (only works if we are logged in)
    func updateUserProfile() {
        userProfile = nil;
        
        guard credManager.loggedIn else { return }
        Task {
            do {
                let privateProfile: [UserProfileResponse] = try await credManager.supabaseClient.rpc("get_profile").execute().value
                if !privateProfile.isEmpty {
                    await MainActor.run {
                        userProfile = privateProfile[0]
                    }
                }
            } catch {
                print("Error fetching user profile: \(error)")
            }
        }
    }
    
    /// Sends a friend request to another user using their friend code
    func sendFriendRequest(friendCode: String) {
        guard credManager.loggedIn else { return };
        guard !friendCode.isEmpty else { return };
        
        Task {
            do {
                try await credManager.fastAPI.sendFriendRequest(FastAPIClient.SendFriendRequestParams(receiver_friend_code: friendCode))
                AnalyticsManager.shared.trackFriendRequestSent()
                await MainActor.run {
                    errorMessage = nil
                    // Trigger a refresh of the request list
                    requestListRefreshTrigger = UUID()
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    var body: some View {
        ZStack {
            Background()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            ScrollView {
                VStack(spacing: 20) {
                    if credManager.loggedIn {
                        // Display incoming friend requests at the top
                        SettingsView.SettingButton(text: "View Requests", onSelect: { router.toViewRequests() })
                        
                        if let profile = userProfile {
                            VStack(spacing: 20) {
                                FriendQRInvite(data: "shutuptimer://friend-invite?code=\(profile.friend_code)")
                                
                                // Display the user's friend code
                                CodeDisplay(code: profile.friend_code)
                                
                                // Input section for sending friend requests
                                VStack(spacing: 10) {
                                    FriendCodeAdd(onCommit: sendFriendRequest)
                                    
                                    if let error = errorMessage {
                                        Text(error)
                                            .foregroundColor(.red)
                                            .font(.caption)
                                    }
                                }
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(15)
                            }
                        } else {
                            Text("Loading...")
                        }
                    } else {
                        ZStack {
                            FormattedImages.FriendCodeStripe(width: 350)
                            Text("Login to get friends!")
                                .font(FontTokens.architectsDaughter(size: 30))
                                .minimumScaleFactor(0.5)
                                .foregroundColor(ColorTokens.shade100)
                                .frame(maxWidth: 300)
                        }
                    }
                }
                .padding()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            updateUserProfile()
        }
        .onChange(of: credManager.session) { _ in
            updateUserProfile()
        }
    }
}

struct CodeDisplay : View {
    var code: String;
    var body : some View {
        ZStack {
            FormattedImages.FriendCodeStripe(width: 320)
            Text("Code: \(code)")
                .font(FontTokens.architectsDaughter(size: 30))
                .foregroundColor(ColorTokens.shade100)
        }
    }
}

struct FriendCodeAdd : View {
    @State var text: String = "";
    var onCommit: (String) -> Void
    
    var body : some View {
        ZStack {
            FormattedImages.FriendCodeStripe(width: 320)
            TextField("", text: $text, onCommit: {
                onCommit(text)
                text = ""
            })
                .font(FontTokens.architectsDaughter(size: 25))
                .minimumScaleFactor(0.2)
                .foregroundColor(ColorTokens.shade100)
                .frame(width: 280)
            if text.isEmpty {
                Text("Enter Friend Code")
                    .font(FontTokens.architectsDaughter(size: 25))
                    .minimumScaleFactor(0.2)
                    .foregroundStyle(ColorTokens.shade300)
                    .multilineTextAlignment(.leading)
                    .frame(width: 280, alignment: .leading)
                    .allowsHitTesting(false)
            }
        }
    }
}

#Preview {
    FriendInvite()
        .environmentObject(CredManager())
    // CodeDisplay(code: "12345678")
    // FriendCodeAdd(onCommit: {_ in })
}
