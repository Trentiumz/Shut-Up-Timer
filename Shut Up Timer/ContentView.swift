import SwiftUI

struct ContentView: View {
    @StateObject var router: AppRouter = AppRouter();
    
    init() {
    }
    
    var body: some View {
        NavigationStack(path:$router.path){
            TabView {
                HomeView().tabItem { Label("Home", systemImage: "house")}
                LeaderboardView().tabItem { Label("Leaderboard", systemImage: "list.number")}
                FriendInvite().tabItem { Label("Invite", systemImage: "arrow.up")}
                DisappointmentView().tabItem { Label("Leaderboard", systemImage: "gobackward.10.hi")}
                AccountView().tabItem{ Label("Account", systemImage: "person")}
            }
                .environmentObject(router)
                .navigationDestination(for: AppRoute.self) { value in
                    switch value {
                    case .timer:
                        TimerView(timerViewModel: router.timerViewModel).environmentObject(router)
                    case .timerCompleted(let seconds):
                        TimerCompletedView(timeLocked: seconds).environmentObject(router)
                    default:
                        Text("Invalid")
                    }
                }
        }
    }
}

#Preview {
    ContentView()
}
