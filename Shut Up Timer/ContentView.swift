import SwiftUI

// Control for all pages
struct ContentView: View {
    @EnvironmentObject var router: AppRouter;
    @EnvironmentObject var settings: Settings;
    @EnvironmentObject var sessions: Sessions;
    
    @State var selectedScreen: LandingScreen = .home;
    
    init() {
    }
    
    var body: some View {
        NavigationStack(path:$router.path){
            VStack(spacing: 0) {
                if(settings.firstTime) {
                    // onboarding
                    OnboardingView(onDone: {
                        settings.firstTime = false;
                    })
                } else {
                    TopBarView()
                    TabView(selection: $selectedScreen) {
                        HomeView().tag(LandingScreen.home)
                        SocialMediaView().tag(LandingScreen.socialMedia)
                        LeaderboardView().tag(LandingScreen.leaderboard)
                        DisappointmentView().tag(LandingScreen.disappointment)
                        AccountView().tag(LandingScreen.account)
                    }
                    BottomBarView(selectedScreen: $selectedScreen);
                }
            }	
                .environmentObject(router)
                .onAppear{
                    if let sessionInProgress = TempSessionLoader.getSession() {
                        // if there is an active session, navigate to the timer
                        router.toTimerState(sessionInProgress: sessionInProgress)
                    }
                }
                .navigationDestination(for: PathElement.self) { elem in
                    switch elem.route {
                    case .timer(let timerModel):
                        // timer started
                        TimerView(timerModel: timerModel).environmentObject(router)
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
                            .navigationBarBackButtonHidden(true)
                    case .inviteFriends:
                        // invite friends screen
                        FriendInvite()
                            .environmentObject(router)
                            .navigationBarBackButtonHidden(false)
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
    ContentView()
        .environmentObject(Settings(firstTime: false, difficulty: .asian, roastLevel: .med, timerParam: .countdown(seconds: 20)))
        .environmentObject(SessionsLoader.loadSessions(onUpdate: {_ in }))
        .environmentObject(ToDoLoader.getToDo(onUpdate: {_ in}))
        .environmentObject(CredManager())
        .environmentObject(AppRouter());
}
