import SwiftUI;

struct LeaderboardView : View {
    @EnvironmentObject var credManager: CredManager
    @State private var friendLB: [LBEntry] = []
    
    var body: some View {
        VStack() {
            if credManager.loggedIn {
                ForEach(friendLB) { user in
                    LBRowView(name: user.name, pts: user.pts);
                }
            } else {
                Text("Log in to see your friends' leaderboard")
            }
        }
        .onAppear {
            if credManager.loggedIn {
                Task {
                    do {
                        let data: [FriendLeaderboardResponse] = try await credManager.supabaseClient.rpc("get_friend_leaderboard").execute().value
                        print(data);
                        await MainActor.run {
                            friendLB = data.map{row in
                                return LBEntry(name: row.friend_username, pts: row.friend_iq)};
                        }
                    } catch {
                        print("Error fetching leaderboard: \(error)")
                    }
                }
            }
        }
    }
}
