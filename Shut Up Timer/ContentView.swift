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
                    TopBarView(selectedScreen: $selectedScreen)
                        .zIndex(5)
                    ZStack {
                        HomeView().tag(LandingScreen.home)
                            .opacity(selectedScreen == .home ? 1 : 0)
                            .allowsHitTesting(selectedScreen == .home)
                    
                        SocialMediaView().tag(LandingScreen.socialMedia)
                            .opacity(selectedScreen == .socialMedia ? 1 : 0)
                            .allowsHitTesting(selectedScreen == .socialMedia)
                    
                        LeaderboardView().tag(LandingScreen.leaderboard)
                            .opacity(selectedScreen == .leaderboard ? 1 : 0)
                            .allowsHitTesting(selectedScreen == .leaderboard)
                    
                        DisappointmentView().tag(LandingScreen.disappointment)
                            .opacity(selectedScreen == .disappointment ? 1 : 0)
                            .allowsHitTesting(selectedScreen == .disappointment)
                    
                        ViewThatFits {
                            AccountView().tag(LandingScreen.account)
                                .opacity(selectedScreen == .account ? 1 : 0)
                                .allowsHitTesting(selectedScreen == .account)
                            AccountView().tag(LandingScreen.account)
                                .opacity(selectedScreen == .account ? 1 : 0)
                                .allowsHitTesting(selectedScreen == .account)
                                .frame(width: 350)
                        }
                    }
                    BottomBarView(selectedScreen: $selectedScreen)
                        .zIndex(5);
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
                case .timerCompleted(let session):
                    // timer completed
                    TimerCompletedView(session: session)
                        .navigationBarBackButtonHidden(true)
                case .timerFailed(let session):
                    // timer failed
                    TimerFailedView(session: session)
                        .navigationBarBackButtonHidden(true)
                case .timerFailedCamera(let sessionID):
                    FailedCameraView(sessionID: sessionID)
                        .navigationBarBackButtonHidden(true)
                case .login(let onSuccess):
                    // login screen
                    LoginView(onLoggedIn: onSuccess)
                        .navigationBarBackButtonHidden(true)
                case .inviteFriends:
                    // invite friends screen
                    FriendInvite()
                        .navigationBarBackButtonHidden(false)
                case .viewRequests:
                    RequestListView()
                case .albumView(let month, let year):
                    AlbumView(month: month, year: year)
                case .feedbackView:
                    FeedbackView()
                case .notifications:
                    NotificationsView()
                        .navigationBarBackButtonHidden(true)
                case .addPost:
                    AddPostView()
                        .navigationBarBackButtonHidden(true)
                case .postView(let month, let year):
                    AccountPostView(month: month, year: year)
                        .navigationBarBackButtonHidden(false)
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
                            try await credManager.fastAPI.sendFriendRequest(FastAPIClient.SendFriendRequestParams(receiver_friend_code: data))
                            alertMessage = "Successfully sent friend invite to \(data)"
                            showAlert = true
                        } catch {
                            print("failed url friend invite, \(error.localizedDescription)")
                            alertMessage = "\(error.localizedDescription)"
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
        .environment(ToDoLoader.getToDo())
        .environment(CurUser(credManager: CredManager()))
        .environmentObject(CredManager())
        .environmentObject(AppRouter());
}
