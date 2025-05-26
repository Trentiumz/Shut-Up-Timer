import SwiftUI;

struct LeaderboardView : View {
    @EnvironmentObject var credManager: CredManager
    @State private var friendLB: [LBEntry] = []
    @State private var worldLB: [LBEntry] = []
    @State private var selectedTab: LeaderboardTab = .friends

    enum LeaderboardTab: String, CaseIterable, Identifiable {
        case friends = "Friends"
        case world = "World"

        var id: String { self.rawValue }
    }
    
    var body: some View {
        VStack {
            Picker("Leaderboard", selection: $selectedTab) {
                ForEach(LeaderboardTab.allCases) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding()

            if credManager.loggedIn {
                if selectedTab == .friends {
                    ForEach(friendLB) { user in
                        LBRowView(name: user.name, pts: user.pts)
                    }
                } else {
                    ForEach(worldLB) { user in
                        LBRowView(name: user.name, pts: user.pts)
                    }
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
                                return LBEntry(name: row.username, pfp: row.profile_picture, pts: row.iq)};
                        }

                        // fetch world leaderboard
                        let worldData: [WorldLeaderboardResponse] = try await credManager.supabaseClient.rpc("get_world_leaderboard").execute().value
                        await MainActor.run {
                            worldLB = worldData.map { row in
                                return LBEntry(name: row.username, pfp: row.profile_picture, pts: row.iq)
                            }
                        }
                    } catch {
                        print("Error fetching leaderboard: \(error)")
                    }
                }
            }
        }
    }
}
