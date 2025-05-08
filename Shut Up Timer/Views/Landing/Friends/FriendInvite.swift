import SwiftUI;

/// A view that handles friend-related functionality including:
/// - Displaying incoming friend requests
/// - Showing the user's friend code
/// - Allowing users to send friend requests to others
struct FriendInvite : View {
    @EnvironmentObject var credManager: CredManager;
    @State private var userProfile: UserProfileResponse? = nil;
    @State private var friendCode: String = "";
    @State private var errorMessage: String? = nil;
    @State private var requestListRefreshTrigger = UUID();
    
    /// Fetches the user's profile information including their friend code
    func updateUserProfile() {
        userProfile = nil;
        Task {
            do {
                let privateProfile: [UserProfileResponse] = try await credManager.supabaseClient.rpc("get_profile").execute().value
                await MainActor.run {
                    userProfile = privateProfile[0]
                }
            } catch {
                print("Error fetching user profile: \(error)")
            }
        }
    }
    
    /// Sends a friend request to another user using their friend code
    func sendFriendRequest() {
        guard !friendCode.isEmpty else { return }
        
        Task {
            do {
                try await credManager.supabaseClient.rpc("send_friend_request", params: ["receiver_friend_code": friendCode]).execute()
                await MainActor.run {
                    friendCode = ""
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
        VStack(spacing: 20) {
            if credManager.loggedIn {
                // Display incoming friend requests at the top
                RequestList()
                    .frame(maxHeight: 200)
                    .id(requestListRefreshTrigger) // This will force a refresh when the trigger changes
                
                if let profile = userProfile {
                    VStack(spacing: 20) {
                        // Display the user's friend code
                        Text("Your Friend Code")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        HStack {
                            Image(systemName: "person.2.fill")
                                .foregroundColor(.blue)
                                .font(.title)
                            Text(profile.friend_code)
                                .font(.title)
                                .fontWeight(.semibold)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(15)
                        
                        // Input section for sending friend requests
                        VStack(spacing: 10) {
                            Text("Send Friend Request")
                                .font(.headline)
                            
                            TextField("Send Request (code)", text: $friendCode, onCommit: sendFriendRequest)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.none)
                            
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
                Text("Log in to see your friend code")
            }
        }
        .padding()
        .onAppear {
            updateUserProfile()
        }
        .onChange(of: credManager.session) {
            updateUserProfile()
        }
    }
}

#Preview {
    FriendInvite()
        .environmentObject(CredManager())
} 