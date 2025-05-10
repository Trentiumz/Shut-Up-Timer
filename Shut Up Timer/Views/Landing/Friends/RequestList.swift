import SwiftUI;

/// A view that displays a list of incoming friend requests for the current user
struct RequestList : View {
    @EnvironmentObject var credManager: CredManager;
    @State private var requests: [FriendRequestResponse] = [];
    @State private var userProfiles: [UUID: UserPublicProfileResponse] = [:];
    
    /// Fetches the latest friend requests from the server
    func updateRequests() {
        Task {
            do {
                let data: [FriendRequestResponse] = try await credManager.supabaseClient.rpc("get_friend_requests").execute().value
                await MainActor.run {
                    // Sort requests: current user as receiver first, then others
                    if let currentUserId = credManager.session?.user.id {
                        requests = data.sorted { request1, request2 in
                            let isReceiver1 = request1.receiver_id == currentUserId
                            let isReceiver2 = request2.receiver_id == currentUserId
                            if isReceiver1 && !isReceiver2 {
                                return true
                            } else if !isReceiver1 && isReceiver2 {
                                return false
                            }
                            return request1.created_at < request2.created_at // Secondary sort by creation date
                        }
                    } else {
                        requests = data
                    }
                    // Fetch profiles for all unique users in the requests
                    for user in data {
                        fetchUserProfile(for: user.sender_id)
                        fetchUserProfile(for: user.receiver_id)
                    }
                }
            } catch {
                print("Error fetching friend requests: \(error)")
            }
        }
    }
    
    /// Fetches the public profile for a given user ID
    func fetchUserProfile(for userId: UUID) {
        Task {
            do {
                let profile: [UserPublicProfileResponse] = try await credManager.supabaseClient.rpc("get_user_public_profile", params: ["user_id": userId]).execute().value
                if let userProfile = profile.first {
                    await MainActor.run {
                        userProfiles[userId] = userProfile
                    }
                } else {
                    print("No profile found for user \(userId)")
                }
            } catch {
                print("Error fetching profile for user \(userId): \(error)")
            }
        }
    }
    
    /// Handles responding to a friend request (accept/reject)
    func respondToRequest(requestId: Int, action: String) {
        Task<Void, Never> {
            do {
                try await credManager.supabaseClient.rpc("respond_to_friend_request", params: [
                    "request_id": String(requestId),
                    "action": action
                ]).execute()
                // Refresh the requests list after responding
                await MainActor.run {
                    updateRequests()
                }
            } catch {
                print("Error responding to friend request: \(error)")
            }
        }
    }
    
    var body: some View {
        VStack {
            if credManager.loggedIn {
                if requests.isEmpty {
                    Text("No friend requests")
                        .foregroundColor(.gray)
                } else {
                    // Display each friend request in a simple format
                    List(requests, id: \.id) { request in
                        HStack {
                            Text("From \(userProfiles[request.sender_id]?.username ?? request.sender_id.uuidString) to \(userProfiles[request.receiver_id]?.username ?? request.receiver_id.uuidString)")
                            Spacer()
                            // Only show buttons if current user is the receiver
                            if credManager.session?.user.id == request.receiver_id {
                                Button(action: {
                                    respondToRequest(requestId: request.id, action: "accept")
                                }) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                }
                                Button(action: {
                                    respondToRequest(requestId: request.id, action: "reject")
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                }
            } else {
                Text("Log in to see friend requests")
            }
        }
        .padding()
        .onAppear {
            updateRequests()
        }
        .onChange(of: credManager.session) {
            updateRequests()
        }
    }
}

#Preview {
    RequestList()
        .environmentObject(CredManager())
} 
