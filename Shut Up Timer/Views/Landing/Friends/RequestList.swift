import SwiftUI;

struct RequestListView : View {
    @State private var searchText = ""
    @State private var incomingRequests: [FriendRequestResponse] = []
    @State private var sentRequests: [SentRequestResponse] = []
    @EnvironmentObject var credManager: CredManager
    @EnvironmentObject var notificationManager: NotificationManager
    
    var filteredIncomingRequests: [FriendRequestResponse] {
        if searchText.isEmpty {
            return incomingRequests
        } else {
            return incomingRequests.filter {
                $0.username?.localizedCaseInsensitiveContains(searchText) ?? false
            }
        }
    }
    
    var filteredSentRequests: [SentRequestResponse] {
        if searchText.isEmpty {
            return sentRequests
        } else {
            return sentRequests.filter {
                $0.username?.localizedCaseInsensitiveContains(searchText) ?? false
            }
        }
    }
    
    var body : some View {
        ZStack {
            Background()
            VStack(spacing: 20) {
                // Title
                HStack {
                    Text("FRIEND REQUEST")
                        .font(FontTokens.architectsDaughter(size: 30))
                        .foregroundColor(ColorTokens.shade100)
                        .padding(.top, 20)
                    Spacer()
                }
                
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(ColorTokens.shade700)
                        .padding(.leading, 12)
                    
                    TextField("search", text: $searchText)
                        .font(.system(size: 16))
                        .foregroundColor(ColorTokens.shade700)
                        .padding(.vertical, 8)
                }
                .background(ColorTokens.shade100)
                .cornerRadius(8)
                
                // Content
                ScrollView {
                    VStack(spacing: 20) {
                        if searchText.isEmpty {
                            // When search is empty, show sections separately
                            if filteredIncomingRequests.isEmpty && filteredSentRequests.isEmpty {
                                Text("No friend requests")
                                    .font(FontTokens.architectsDaughter(size: 25))
                                    .foregroundColor(ColorTokens.shade700)
                            } else {
                                // Incoming requests section
                                if !filteredIncomingRequests.isEmpty {
                                    RequestList(
                                        requests: filteredIncomingRequests,
                                        onAccept: { requestId in acceptFriendRequest(requestId: requestId) },
                                        onDecline: { requestId in removeFriendRequest(requestId: requestId) }
                                    )
                                }
                                
                                // Sent requests section
                                if !filteredSentRequests.isEmpty {
                                    SentList(
                                        requests: filteredSentRequests,
                                        onWithdraw: { requestId in withdrawRequest(requestId: requestId) }
                                    )
                                }
                            }
                        } else {
                            // When search has text, combine all results
                            if filteredIncomingRequests.isEmpty && filteredSentRequests.isEmpty {
                                Text("No results found")
                                    .font(FontTokens.architectsDaughter(size: 20))
                                    .foregroundColor(ColorTokens.shade300)
                                    .padding(.top, 20)
                            } else {
                                VStack(spacing: 10) {
                                    // Show incoming requests first
                                    if !filteredIncomingRequests.isEmpty {
                                        RequestList(
                                            requests: filteredIncomingRequests,
                                            onAccept: { requestId in acceptFriendRequest(requestId: requestId) },
                                            onDecline: { requestId in removeFriendRequest(requestId: requestId) }
                                        )
                                    }
                                    
                                    // Show sent requests second
                                    if !filteredSentRequests.isEmpty {
                                        SentList(
                                            requests: filteredSentRequests,
                                            onWithdraw: { requestId in withdrawRequest(requestId: requestId) }
                                        )
                                    }
                                }
                            }
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
            .padding(.horizontal, 20)
        }
        .onAppear {
            updateRequests()
        }
        .onChange(of: credManager.session) { _ in
            updateRequests()
        }
        .onChange(of: notificationManager.notifications) { _ in
            updateRequests()
        }
    }
    
    /// Fetches both incoming and sent friend requests from the server
    func updateRequests() {
        guard credManager.loggedIn else { return }
        
        // Fetch incoming requests
        Task {
            do {
                let incomingData: [FriendRequestResponse] = try await credManager.supabaseClient.rpc("get_friend_requests").execute().value
                await MainActor.run {
                    incomingRequests = incomingData
                }
            } catch {
                print("Error fetching incoming friend requests: \(error)")
            }
        }
        
        // Fetch sent requests
        Task {
            do {
                let sentData: [SentRequestResponse] = try await credManager.supabaseClient.rpc("get_sent_requests").execute().value
                await MainActor.run {
                    sentRequests = sentData
                }
            } catch {
                print("Error fetching sent friend requests: \(error)")
            }
        }
    }
    
    /// Handles accepting a friend request
    func acceptFriendRequest(requestId: Int) {
        guard credManager.loggedIn else { return }
        Task {
            do {
                try await credManager.acceptFriendRequest(requestId);
                AnalyticsManager.shared.trackFriendRequestAccepted()
                updateRequests();
            } catch {
                print("Error accepting friend request: \(error)");
            }
        }
    }
    
    /// Handles declining a friend request
    func removeFriendRequest(requestId: Int) {
        guard credManager.loggedIn else { return }
        Task {
            do {
                try await credManager.removeFriendRequest(requestId);
                updateRequests()
            } catch {
                print("Error declining friend request: \(error)")
            }
        }
    }
    
    /// Handles withdrawing a sent friend request
    func withdrawRequest(requestId: Int) {
        guard credManager.loggedIn else { return }
        Task {
            do {
                try await credManager.removeFriendRequest(requestId);
                updateRequests()
            } catch {
                print("Error withdrawing friend request: \(error)")
            }
        }
    }
}

// MARK: - RequestList Component (Incoming Requests)
struct RequestList: View {
    let requests: [FriendRequestResponse]
    let onAccept: (Int) -> Void
    let onDecline: (Int) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(spacing: 10) {
                ForEach(requests, id: \.id) { request in
                    FriendRequestRow(
                        username: request.username ?? "",
                        profilePicture: request.pfp ?? "",
                        isSentRequest: false,
                        onAccept: { onAccept(request.id) },
                        onDecline: { onDecline(request.id) },
                        onWithdraw: {}
                    )
                }
            }
        }
    }
}

// MARK: - SentList Component (Sent Requests)
struct SentList: View {
    let requests: [SentRequestResponse]
    let onWithdraw: (Int) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("SENT REQUEST")
                .font(FontTokens.architectsDaughter(size: 20))
                .foregroundColor(ColorTokens.shade100)
                .padding(.horizontal, 20)
            
            VStack(spacing: 10) {
                ForEach(requests, id: \.id) { request in
                    FriendRequestRow(
                        username: request.username ?? "",
                        profilePicture: request.pfp ?? "",
                        isSentRequest: true,
                        onAccept: {},
                        onDecline: {},
                        onWithdraw: { onWithdraw(request.id) }
                    )
                }
            }
        }
    }
}

// MARK: - Reusable Friend Request Row Component
struct FriendRequestRow: View {
    let username: String
    let profilePicture: String
    let isSentRequest: Bool
    let onAccept: () -> Void
    let onDecline: () -> Void
    let onWithdraw: () -> Void
    
    var body: some View {
        HStack(alignment: .center, spacing: 20) {
            // Profile picture
            PFPDisplay(url: profilePicture, width: 80, height: 80)
            
            VStack(spacing: 0) {
                HStack(spacing: 8) {
                    if isSentRequest {
                        // Withdraw button for sent requests
                        Button(action: onWithdraw) {
                            ActionButtonStyle(
                                msg: "Withdraw",
                                color: ColorTokens.red300
                            )
                        }
                    } else {
                        // Accept and Decline buttons for incoming requests
                        Button(action: onAccept) {
                            ActionButtonStyle(
                                msg: "Add",
                                color: ColorTokens.red300
                            )
                        }
                        
                        Button(action: onDecline) {
                            ActionButtonStyle(
                                msg: "Reject",
                                color: ColorTokens.shade600
                            )
                        }
                    }
                }
                
                Spacer()
                    .frame(maxHeight: 2)
                
                Text("Username: \(username)")
                    .font(FontTokens.architectsDaughter(size: 18))
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                    .foregroundColor(ColorTokens.shade700)
            }
        }
        .padding()
        .background(ColorTokens.shade200)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(ColorTokens.shade300, lineWidth: 1)
        )
    }
    
    struct ActionButtonStyle: View {
        let msg: String
        let color: Color
        let textColor: Color = ColorTokens.shade100
        
        var body: some View {
            Text(msg)
                .font(FontTokens.architectsDaughter(size: 24))
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .foregroundColor(textColor)
                .padding(.vertical, 2)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(color)
                )
        }
    }
}

#Preview {
//    RequestListView()
//        .environmentObject(CredManager())
//        .environmentObject(NotificationManager())
    
    FriendRequestRow(username: "Testing", profilePicture: "", isSentRequest: false, onAccept: {}, onDecline: {}, onWithdraw: {})
}
