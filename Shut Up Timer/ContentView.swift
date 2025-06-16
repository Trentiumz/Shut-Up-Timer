import SwiftUI

// Control for all pages
struct ContentView: View {
    @EnvironmentObject var router: AppRouter;
    @EnvironmentObject var settings: Settings;
    @EnvironmentObject var sessions: Sessions;
    @EnvironmentObject var credManager: CredManager;
    
    @State var selectedScreen: LandingScreen = .home;
    @State var showAlert: Bool = false;
    @State var alertMessage: String = "";
    
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
                    .tabViewStyle(.page(indexDisplayMode: .never))
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
                case .viewRequests:
                    RequestListView()
                default:
                    Text("Invalid")
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            requestNotificationPermission()
        }.onOpenURL(perform: { url in
            if url.scheme == "shutuptimer",
               url.host == "friend-invite",
                let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                 let data = components.queryItems?.first(where: { $0.name == "code" })?.value {
                if credManager.loggedIn {
                    Task {
                        do {
                            try await credManager.supabaseClient.rpc("send_friend_request", params: ["receiver_friend_code": data]).execute()
                            alertMessage = "Successfully sent friend invite to \(data)"
                            showAlert = true
                        } catch {
                            print("failed url friend invite, \(error.localizedDescription)")
                            alertMessage = "Something went wrong"
                            showAlert = true
                        }
                    }
                }
            }
        })
        .alert("Friend Invite Result", isPresented: $showAlert) {
            Button("Okay", role: .cancel) {}
        } message: {
            Text(alertMessage)
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
