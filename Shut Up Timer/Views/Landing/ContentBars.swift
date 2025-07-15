import SwiftUI;

struct TopBarView : View {
    @EnvironmentObject var curUser: CurUser
    @EnvironmentObject var sessions: Sessions;
    @EnvironmentObject var router: AppRouter;
    @EnvironmentObject var notificationManager: NotificationManager;
    
    @Binding var selectedScreen: LandingScreen;

    private func screenName(_ screen: LandingScreen) -> String {
        switch screen {
        case .home: return "home"
        case .socialMedia: return "social_media"
        case .leaderboard: return "leaderboard"
        case .disappointment: return "disappointment"
        case .account: return "account"
        }
    }
    
    var body: some View {
        HStack{
            Button(action: {
                let previousScreen = selectedScreen
                withAnimation {
                    selectedScreen = .account;
                }
                if previousScreen != .account {
                    AnalyticsManager.shared.trackTabSwitch(from: screenName(previousScreen), to: "account")
                    AnalyticsManager.shared.trackScreenView("account")
                }
            }) {
                PFPDisplay(url: curUser.userPublicProfile?.profile_picture ?? "", width: 32, height: 32)
            }
            
            Button(action: {
                AnalyticsManager.shared.trackScreenView("feedback")
                router.toFeedbackView();
            }) {
                Image(systemName: "bubble.left")
                    .resizable()
                    .foregroundStyle(ColorTokens.shade700)
                    .frame(width: 32, height: 32)
            }
            Spacer()
            
            Button(action: {
                AnalyticsManager.shared.trackScreenView("invite_friends")
                router.toInviteFriends();
                // Add your action here
            }) {
                Image(systemName: "qrcode")
                    .font(.system(size: 32))
                    .foregroundStyle(ColorTokens.shade700)
            }
            .buttonStyle(PlainButtonStyle())
            
            Button(action: {
                AnalyticsManager.shared.trackScreenView("notifications")
                router.toNotifications();
            }) {
                ZStack(alignment: .bottomTrailing) {
                    Image(systemName: "bell")
                        .font(.system(size: 32))
                        .foregroundStyle(ColorTokens.shade700)
                    if notificationManager.notifications.count > 0 {
                        Text("\(notificationManager.notifications.count)")
                            .font(.system(size: 14, weight: .bold))
                            .minimumScaleFactor(0.7)
                            .foregroundColor(ColorTokens.shade100)
                            .frame(width: 16, height: 16)
                            .background(Circle().fill(ColorTokens.red100))
                            .overlay(Circle().stroke(Color.white, lineWidth: 1))
                            .offset(x: 4, y: 8)
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Button(action: {
                AnalyticsManager.shared.trackScreenView("add_post")
                router.toAddPost();
            }) {
                Image(systemName: "plus.square")
                    .font(.system(size: 32))
                    .foregroundStyle(ColorTokens.shade700)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding()
        .background(ColorTokens.red300)
        .onAppear {
            curUser.refresh(animated: true)
        }
    }
}

enum LandingScreen {
    case home;
    case socialMedia;
    case leaderboard;
    case disappointment;
    case account;
}

struct BottomBarView : View {
    @Binding var selectedScreen: LandingScreen;
    
    init(selectedScreen : Binding<LandingScreen>) {
        self._selectedScreen = selectedScreen;
    }
    
    struct IconImage : View {
        var systemName: String;
        
        var buttonStyle = Color.black;
        var buttonSize: CGFloat = 40;
        
        init(_ systemName: String) {
            self.systemName = systemName;
        }
        
        var body : some View {
            Image(systemName: systemName)
                .foregroundStyle(buttonStyle)
                .font(.system(size: buttonSize))
        }
    }
    
    var body : some View {
        HStack {
            Button(action: {
                let previousScreen = selectedScreen
                withAnimation {
                    selectedScreen = .home
                }
                if previousScreen != .home {
                    AnalyticsManager.shared.trackTabSwitch(from: screenName(previousScreen), to: "home")
                    AnalyticsManager.shared.trackScreenView("home")
                }
            }){
                IconImage("house.fill")
            }
            Spacer()
            Button(action: {
                let previousScreen = selectedScreen
                withAnimation {
                    selectedScreen = .socialMedia
                }
                if previousScreen != .socialMedia {
                    AnalyticsManager.shared.trackTabSwitch(from: screenName(previousScreen), to: "social_media")
                    AnalyticsManager.shared.trackScreenView("social_media")
                }
            }){
                IconImage("person.2.fill")
            }
            Spacer()
            Button(action: {
                let previousScreen = selectedScreen
                withAnimation {
                    selectedScreen = .leaderboard
                }
                if previousScreen != .leaderboard {
                    AnalyticsManager.shared.trackTabSwitch(from: screenName(previousScreen), to: "leaderboard")
                    AnalyticsManager.shared.trackScreenView("leaderboard")
                }
            }){
                IconImage("list.number")
            }
            Spacer()
            Button(action: {
                let previousScreen = selectedScreen
                withAnimation {
                    selectedScreen = .disappointment
                }
                if previousScreen != .disappointment {
                    AnalyticsManager.shared.trackTabSwitch(from: screenName(previousScreen), to: "disappointment")
                    AnalyticsManager.shared.trackScreenView("disappointment")
                }
            }){
                IconImage("photo.fill")
            }
            Spacer()
            Button(action: {
                let previousScreen = selectedScreen
                withAnimation {
                    selectedScreen = .account
                }
                if previousScreen != .account {
                    AnalyticsManager.shared.trackTabSwitch(from: screenName(previousScreen), to: "account")
                    AnalyticsManager.shared.trackScreenView("account")
                }
            }){
                IconImage("gearshape.fill")
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 30)
        .frame(height: 60)
        .background(ColorTokens.red300)
    }
    
    private func screenName(_ screen: LandingScreen) -> String {
        switch screen {
        case .home: return "home"
        case .socialMedia: return "social_media"
        case .leaderboard: return "leaderboard"
        case .disappointment: return "disappointment"
        case .account: return "account"
        }
    }
}

struct BarViewPreviews : PreviewProvider {
    
    struct Wrapper :  View {
        @State var selectedScreen : LandingScreen = .home;
        
        var body : some View {
            VStack {
                TopBarView(selectedScreen: $selectedScreen)
                    .environmentObject(CurUser(credManager: CredManager()))
                    .environmentObject(SessionsLoader.loadSessions())
                    .environmentObject(AppRouter())
                    .environmentObject(NotificationManager())
                    .environmentObject(ToDoLoader.getToDo())
                Spacer()
            }
//            VStack {
//                Spacer();
//                BottomBarView(selectedScreen: $selectedScreen)
//            }
        }
    }
        
    
    static var previews : some View {
        Wrapper()
    }
}
