import SwiftUI
import FamilyControls

// Control for all pages
struct ContentView: View {
    @EnvironmentObject var router: AppRouter;
    @EnvironmentObject var settings: Settings;
    @EnvironmentObject var sessions: SessionLoader;
    @EnvironmentObject var credManager: CredManager;
    @EnvironmentObject var subscriptionManager: SubscriptionManager;
    
    @State var showAlert: Bool = false;
    @State var alertMessage: String = "";
    @Environment(\.scenePhase) private var scenePhase
    
    init() {
        
    }
    
    var body: some View {
        NavigationStack(path:$router.path){
            if(settings.firstTime) {
                // onboarding
                OnboardingView(onDone: {
                    AnalyticsManager.shared.trackOnboardingComplete()
                    settings.firstTime = false;
                })
            } else if(subscriptionManager.isLoading) {
                // Show loading screen while checking subscription status
                ZStack {
                    Color.white.ignoresSafeArea()
                    VStack(spacing: 16) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(1.5)
                        Text("Loading...")
                            .font(.body)
                            .foregroundColor(Color("ColorlyShadeShade600"))
                    }
                }
            } else if(subscriptionManager.currentSubscription == nil) {
                // Show subscription purchase view if not subscribed
                SubscriptionPurchaseView()
                    .ignoresSafeArea(.keyboard)
            } else {
                LandingView()
                    .ignoresSafeArea(.keyboard)
                    .navigationDestination(for: PathElement.self) { elem in
                        switch elem.route {
                        case .noLeaveTimer(let timerModel):
                            // timer started
                            TimerView(timerModel: timerModel).environmentObject(router)
                                .navigationBarBackButtonHidden(true)
                        case .appBlockTimer(let timerModel):
                            // app block timer started
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
                        case .albumView:
                            AlbumView()
                        case .achievementsView:
                            AchievementsView()
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
        }
        .environmentObject(router)
        .onAppear{
            if let sessionInProgress = TempSessionLoader.getSession() {
                // if there is an active session, navigate to the timer
                let sessionWrapper = CurSessionManagerType(from: sessionInProgress)
                router.toTimerState(sessionInProgress: sessionWrapper, appReopened: true)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            requestNotificationPermission()
        }
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .background:
                AnalyticsManager.shared.trackAppBackground()
            case .active:
                AnalyticsManager.shared.trackAppForeground()
            case .inactive:
                break // Don't track inactive state
            @unknown default:
                break
            }
        }
        .onOpenURL(perform: { url in
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
        .environmentObject(Settings(firstTime: false, difficulty: .asian, roastLevel: .med, timerParam: .countdown(seconds: 20), defaultBlockedApps: FamilyActivitySelection(), appsToMonitor: FamilyActivitySelection()))
        .environmentObject(CurUser(credManager: CredManager()))
        .environmentObject(CredManager())
        .environmentObject(AppRouter());
}
