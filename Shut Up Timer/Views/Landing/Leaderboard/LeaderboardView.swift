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
        ZStack {
            Background()
            ScrollView {
                VStack {
                    HStack(spacing: 0) {
                        ForEach(LeaderboardTab.allCases) { tab in
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
                            .onTapGesture {
                                withAnimation {
                                    selectedTab = tab;
                                }
                                AnalyticsManager.shared.trackLeaderboardViewed(type: tab.rawValue.lowercased())
                            }
                        }
                    }
                    .padding()
                    
                    if credManager.loggedIn {
                        if selectedTab == .friends {
                            LBContentView(entries: friendLB)
                        } else {
                            LBContentView(entries: worldLB)
                        }
                    } else {
                        Text(selectedTab == .friends ? "Log in to see your friends' leaderboard" : "Log in to see the world leaderboard")
                    }
                }
            }
        }
        .onAppear {
            updateLeaderboardData()
            // temporary testing update
            // friendLB = [LBEntry(name: "Hello There!", pfp: "kalsdf", pts: 52)]
        }
    }
    
    func updateLeaderboardData() {
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

#Preview {
    LeaderboardView()
        .environmentObject(CredManager(subscriptionManager: SubscriptionManager()))
}
