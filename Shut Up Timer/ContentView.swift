import SwiftUI

// Control for all pages
struct ContentView: View {
    @EnvironmentObject var router: AppRouter;
    @EnvironmentObject var settings: Settings;
    
    init() {
    }
    
    var body: some View {
        NavigationStack(path:$router.path){
            VStack {
                if(settings.firstTime) {
                    // onboarding
                    OnboardingView(onDone: {
                        settings.firstTime = false;
                    })
                } else {
                    TopBarView()
                    TabView {
                        HomeView().tabItem { Label("Home", systemImage: "house")}
                        LeaderboardView().tabItem { Label("Leaderboard", systemImage: "list.number")}
                        FriendInvite().tabItem { Label("Invite", systemImage: "arrow.up")}
                        DisappointmentView().tabItem { Label("Disappointment", systemImage: "gobackward.10.hi")}
                        AccountView().tabItem{ Label("Account", systemImage: "person")}
                    }
                }
            }	
                .environmentObject(router)
                .navigationDestination(for: AppRoute.self) { value in
                    switch value {
                    case .timer:
                        // timer started
                        TimerView(timerViewModel: router.timerViewModel).environmentObject(router)
                            .navigationBarBackButtonHidden(true)
                    case .timerCompleted(let seconds):
                        // timer completed
                        TimerCompletedView(timeLocked: seconds)
                            .environmentObject(router)
                            .navigationBarBackButtonHidden(true)
                    case .timerFailed(let seconds):
                        // timer failed
                        TimerFailedView(timeLocked: seconds)
                            .environmentObject(router)
                            .navigationBarBackButtonHidden(true)
                    case .login(let onSuccess):
                        // login screen
                        LoginView(onLoggedIn: onSuccess)
                    default:
                        Text("Invalid")
                    }
                }
        }
    }
}

#Preview {
    ContentView().environmentObject(AppRouter());
}
