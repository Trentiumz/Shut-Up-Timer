import SwiftUI;

/// A view that displays a list of incoming friend requests for the current user
struct RequestList : View {
    @EnvironmentObject var credManager: CredManager;
    @State private var requests: [FriendRequestResponse] = [];
    
    /// Fetches the latest friend requests from the server
    func updateRequests() {
        Task {
            do {
                let data: [FriendRequestResponse] = try await credManager.supabaseClient.rpc("get_friend_requests").execute().value
                await MainActor.run {
                    requests = data
                }
            } catch {
                print("Error fetching friend requests: \(error)")
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
                        Text("From \(request.sender_id) to \(request.receiver_id)")
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