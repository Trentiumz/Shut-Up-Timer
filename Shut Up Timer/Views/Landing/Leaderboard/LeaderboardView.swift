import SwiftUI;

struct LeaderboardView : View {
    @EnvironmentObject var credManager: CredManager
    @State private var friendLB: [LBEntry] = []
    
    var body: some View {
        VStack() {
            ForEach(friendLB) { user in
                LBRowView(name: user.name, pts: user.pts);
            }
        }
        .onAppear {
            Task {
                do {
                    let result = try await credManager.supabaseClient.functions.invoke("get_friend_leaderboard")
                    if let data = result.data as? [[String: Any]] {
                        friendLB = data.compactMap { entry in
                            guard let name = entry["name"] as? String,
                                  let pts = entry["pts"] as? Int else {
                                return nil
                            }
                            return LBEntry(name: name, pts: pts)
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
        .environmentObject(CredManager())
}
