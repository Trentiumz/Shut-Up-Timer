import SwiftUI

// Control for all pages
struct ContentView: View {
    @EnvironmentObject var router: AppRouter;
    @EnvironmentObject var settings: Settings;
    @EnvironmentObject var sessions: Sessions;
    
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
                        SocialMediaView().tabItem {
                            Label("Friends", systemImage: "person.2")
                        }
                        FriendInvite().tabItem { Label("Invite", systemImage: "arrow.up")}
                        DisappointmentView().tabItem { Label("Disappointment", systemImage: "gobackward.10.hi")}
                        AccountView().tabItem{ Label("Account", systemImage: "person")}
                    }
                }
            }	
                .environmentObject(router)
                .onAppear{
                    if let sessionInProgress = TempSessionLoader.getSession() {
                        // if there is an active session, navigate to the timer
                        let curRoast = getRandomRoast();
                        sessions.sessions.append(
                            SessionEntry(tasks: sessionInProgress.tasks,
                                         started: sessionInProgress.startTime,
                                         ended: sessionInProgress.lasUpdate,
                                         timeLocked: TimeInterval(sessionInProgress.timeLocked),
                                         plannedTime: TimeInterval(sessionInProgress.plannedTime),
                                         success: false,
                                         roast: curRoast));
                        TempSessionLoader.clearSession();
                        router.toTimerFailed(totTime: Int(sessionInProgress.plannedTime), roast: curRoast);
                    }
                }
                .navigationDestination(for: PathElement.self) { elem in
                    switch elem.route {
                    case .timer:
                        // timer started
                        TimerView(timerViewModel: router.timerViewModel, selectedTodo: $router.timerViewModel.curTodo).environmentObject(router)
                            .navigationBarBackButtonHidden(true)
                    case .timerCompleted(let seconds):
                        // timer completed
                        TimerCompletedView(timeLocked: seconds)
                            .environmentObject(router)
                            .navigationBarBackButtonHidden(true)
                    case .timerFailed(let seconds, let roast):
                        // timer failed
                        TimerFailedView(timeLocked: seconds, roast: roast)
                            .environmentObject(router)
                            .navigationBarBackButtonHidden(true)
                    case .login(let onSuccess):
                        // login screen
                        LoginView(onLoggedIn: onSuccess)
                    default:
                        Text("Invalid")
                    }
                }
        }.onAppear {
            requestNotificationPermission()
        }
    }

    // Request permission to send notifications (call once)
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            // handle permission response if needed
        }
    }
}

#Preview {
    ContentView().environmentObject(AppRouter());
}
