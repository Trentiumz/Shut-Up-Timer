import SwiftUI;

struct RequestListView : View {
    enum RequestTab: String, CaseIterable, Identifiable {
        case requests
        case sent
        
        var id: String {self.rawValue}
    }
    
    @State var selectedTab = RequestTab.requests;
    
    var body : some View {
        ZStack {
            Background()
            ScrollView {
                VStack(spacing: 10) {
                    BigTag("Friend Requests")
                    
                    HStack(spacing: 0) {
                        ForEach(RequestTab.allCases, id: \.self) { tab in
                            Button(action: {
                                withAnimation {
                                    selectedTab = tab;
                                }
                            }) {
                                ZStack(alignment: .center) {
                                    Rectangle()
                                        .foregroundColor(.clear)
                                        .frame(width: 153, height: 41)
                                        .background(selectedTab == tab ? ColorTokens.red300 : ColorTokens.shade300)
                                        .overlay(
                                            Rectangle()
                                                .inset(by: 1)
                                                .stroke(ColorTokens.shade700, lineWidth: 2)
                                        )
                                    Text(tab.rawValue)
                                        .font(FontTokens.architectsDaughter(size: 20))
                                        .foregroundColor(selectedTab == tab ? ColorTokens.shade100 : ColorTokens.shade700)
                                }
                            }
                        }
                    }
                    .padding()
                    .zIndex(100)
                    
                    switch(selectedTab) {
                    case .requests:
                        RequestList()
                    case .sent:
                        SentList()
                    }
                    Spacer()
                }
            }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
    
    struct BigTag : View {
        var text: String
        init(_ text: String) {
            self.text = text;
        }
        
        var body : some View {
            ZStack(alignment: .leading) {
                FormattedImages.FriendCodeStripe(width: 300)
                Text(text)
                    .font(FontTokens.architectsDaughter(size: 30))
                    .foregroundColor(ColorTokens.shade100)
                    .padding(.leading, 20)
            }
        }
    }
}

fileprivate struct SentList : View {
    @EnvironmentObject var credManager: CredManager;
    @State private var requests: [SentRequestResponse] = [];
    @EnvironmentObject var notificationManager: NotificationManager;
    
    /// Fetches the latest friend requests from the server
    func updateRequests() {
        guard credManager.loggedIn else { return }
        Task {
            do {
                let data: [SentRequestResponse] = try await credManager.supabaseClient.rpc("get_sent_requests").execute().value
                await MainActor.run {
                    // Sort requests: current user as receiver first, then others
                    requests = data
                }
            } catch {
                print("Error fetching friend requests: \(error)")
            }
        }
    }
    
    func withdrawRequest(requestId: Int) {
        guard credManager.loggedIn else { return }
        Task {
            do {
                try await credManager.removeFriendRequest(requestId);
                updateRequests()
            } catch {
                print("Error withdrawing from friend request: \(error)")
            }
        }
    }
    
    var body: some View {
        VStack {
            Spacer().frame(maxHeight: 10)
            if credManager.loggedIn {
                if requests.isEmpty {
                    ZStack(alignment: .top) {
                        FormattedImages.LinedImageBackground(width: 300)
                        Text("No friend requests")
                            .font(FontTokens.architectsDaughter(size: 25))
                            .foregroundColor(ColorTokens.shade700)
                    }
                } else {
                    // Display each friend request in a simple format
                    SentContentView(
                        requests: requests,
                        onWithdraw: { id in withdrawRequest(requestId: id)}
                    )
                }
            } else {
                Text("Log in to see friend requests")
                    .font(FontTokens.architectsDaughter(size: 25))
                    .foregroundColor(ColorTokens.shade700)
            }
        }
        .onAppear {
            updateRequests()
        }
        .onChange(of: credManager.session) {
            updateRequests()
        }
        .onChange(of: notificationManager.notifications) {
            updateRequests()
        }
    }
}

/// A view that displays a list of incoming friend requests for the current user
fileprivate struct RequestList : View {
    @EnvironmentObject var credManager: CredManager;
    @State private var requests: [FriendRequestResponse] = [];
    @EnvironmentObject var notificationManager: NotificationManager;
    
    /// Fetches the latest friend requests from the server
    func updateRequests() {
        guard credManager.loggedIn else { return }
        Task {
            do {
                let data: [FriendRequestResponse] = try await credManager.supabaseClient.rpc("get_friend_requests").execute().value
                await MainActor.run {
                    // Sort requests: current user as receiver first, then others
                    requests = data
                }
            } catch {
                print("Error fetching friend requests: \(error)")
            }
        }
    }
    
    /// Handles responding to a friend request (accept/reject)
    func acceptFriendRequest(requestId: Int) {
        guard credManager.loggedIn else { return }
        Task {
            do {
                try await credManager.acceptFriendRequest(requestId);
                updateRequests();
            } catch {
                print("Error responding to friend request: \(error)");
            }
        }
    }
    
    func removeFriendRequest(requestId: Int) {
        guard credManager.loggedIn else { return }
        Task {
            do {
                try await credManager.removeFriendRequest(requestId);
                updateRequests()
            } catch {
                print("Error responding to friend request: \(error)")
            }
        }
    }
    
    var body: some View {
        VStack {
            Spacer().frame(maxHeight: 10)
            if credManager.loggedIn {
                if requests.isEmpty {
                    ZStack(alignment: .top) {
                        FormattedImages.LinedImageBackground(width: 300)
                        Text("No friend requests")
                            .font(FontTokens.architectsDaughter(size: 25))
                            .foregroundColor(ColorTokens.shade700)
                    }
                } else {
                    // Display each friend request in a simple format
                    FriendRequestContentView(
                        requests: requests,
                        onAccept: { id in acceptFriendRequest(requestId: id)},
                        onDecline: { id in removeFriendRequest(requestId: id)}
                    )
                }
            } else {
                Text("Log in to see friend requests")
                    .font(FontTokens.architectsDaughter(size: 25))
                    .foregroundColor(ColorTokens.shade700)
            }
        }
        .onAppear {
            updateRequests()
        }
        .onChange(of: credManager.session) {
            updateRequests()
        }
        .onChange(of: notificationManager.notifications) {
            updateRequests()
        }
    }
}

fileprivate struct SingleRequestView : View {
    var display: String;
    var canRespond: Bool;
    var onAccept: () -> Void;
    var onDecline: () -> Void;
    
    var body : some View {
        HStack {
            Text(display)
                .font(FontTokens.architectsDaughter(size: 25))
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            Spacer()
        }
        .swipeActions(edge: .leading) {
            if canRespond {
                Button {
                    onAccept()
                } label: {
                    Label("Check", systemImage: "checkmark")
                }
                .tint(.green)
            }
        }
        .swipeActions(edge: .trailing) {
            Button() {
                onDecline()
            } label: {
                Label("Delete", systemImage: "trash")
            }
            .tint(.red)
        }
    }
}

#Preview {
    RequestListView()
        .environmentObject(CredManager())
}
