import SwiftUI;

struct TopBarView : View {
    @EnvironmentObject var curUser: CurUser
    @EnvironmentObject var sessions: SessionLoader;
    @EnvironmentObject var router: AppRouter;
    @EnvironmentObject var notificationManager: NotificationManager;
    
    @Binding var selectedScreen: LandingScreen;

    private func screenName(_ screen: LandingScreen) -> String {
        switch screen {
        case .tasks: return "tasks"
        case .timer: return "timer"
        case .posts: return "posts"
        case .stats: return "stats"
        case .settings: return "settings"
        }
    }
    
    var body: some View {
        HStack{
            // App title on the left
            Text("Shut Up Timer >")
                .font(FontTokens.architectsDaughter(size: 25))
                .foregroundColor(.white)
            
            Spacer()
            
            // Icons on the right
            Button(action: {
                AnalyticsManager.shared.trackScreenView("invite_friends")
                router.toInviteFriends();
            }) {
                Image(systemName: "qrcode")
                    .font(.system(size: 30))
                    .foregroundStyle(.white)
            }
            .buttonStyle(PlainButtonStyle())
            
            Button(action: {
                AnalyticsManager.shared.trackScreenView("notifications")
                router.toNotifications();
            }) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "bell")
                        .font(.system(size: 30))
                        .foregroundStyle(.white)
                    if notificationManager.notifications.count > 0 {
                        Text("\(notificationManager.notifications.count)")
                            .font(.system(size: 12, weight: .bold))
                            .minimumScaleFactor(0.7)
                            .foregroundColor(.white)
                            .frame(width: 16, height: 16)
                            .background(Circle().fill(ColorTokens.red100))
                            .overlay(Circle().stroke(Color.white, lineWidth: 1))
                            .offset(x: 8, y: -4)
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Button(action: {
                AnalyticsManager.shared.trackScreenView("add_post")
                router.toAddPost();
            }) {
                Image(systemName: "plus.square")
                    .font(.system(size: 30))
                    .foregroundStyle(.white)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal)
        .onAppear {
            curUser.refresh(animated: true)
        }
    }
}

enum LandingScreen {
    case tasks;
    case timer;
    case posts;
    case stats;
    case settings;
}

struct BottomBarView : View {
    @Binding var selectedScreen: LandingScreen;
    @EnvironmentObject var curUser: CurUser
    @Environment(\.managedObjectContext) private var viewContext
    
    init(selectedScreen : Binding<LandingScreen>) {
        self._selectedScreen = selectedScreen;
    }
    
    var body : some View {
        HStack(spacing: 0) {
            // Profile picture
            VStack(spacing: 0) {
                PFPDisplay(url: curUser.userPublicProfile?.profile_picture ?? "", width: 70, height: 70)
                    .frame(height: 60, alignment: .top)
                // IQ display
                Text("\(formatIQ(Session.getTotalIQ(context: viewContext))) IQ")
                    .font(FontTokens.architectsDaughter(size: 16))
                    .foregroundColor(.black)
                    .frame(width: 60)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(.black, lineWidth: 1)
                            )
                    )
            }
            .frame(width: 20, height: 70, alignment: .bottomLeading)
            .zIndex(2)
            
            HStack(spacing: 12) {
                // Tab icons in HStack
                HStack(spacing: 8) {
                    ForEach(LandingScreen.allCases, id: \.self) { tab in
                        Button(action: {
                            let previousScreen = selectedScreen
                            withAnimation {
                                selectedScreen = tab
                            }
                            if previousScreen != tab {
                                AnalyticsManager.shared.trackTabSwitch(from: screenName(previousScreen), to: screenName(tab))
                                AnalyticsManager.shared.trackScreenView(screenName(tab))
                            }
                        }) {
                            VStack(spacing: 0) {
                                Image(uiImage: imageForTab(tab))
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 48, height: 40, alignment: .bottom)
                                Text(screenName(tab))
                                    .font(FontTokens.architectsDaughter(size: 16))
                                    .foregroundColor(.black)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(.leading, 50)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(ColorTokens.shade200)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(.black, lineWidth: 1)
                    )
            )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
    
    private func imageForTab(_ tab: LandingScreen) -> UIImage {
        switch tab {
        case .tasks: return FormattedImages.Image145
        case .timer: return FormattedImages.Image147
        case .posts: return FormattedImages.Image144
        case .stats: return FormattedImages.Image124
        case .settings: return FormattedImages.Image146
        }
    }
    
    private func formatIQ(_ iq: Double) -> String {
        let integerPart = Int(iq)
        if integerPart >= 100 {
            return "\(integerPart)"
        } else {
            return String(format: "%.1f", iq)
        }
    }
    
    private func screenName(_ screen: LandingScreen) -> String {
        switch screen {
        case .tasks: return "tasks"
        case .timer: return "timer"
        case .posts: return "posts"
        case .stats: return "stats"
        case .settings: return "settings"
        }
    }
}

extension LandingScreen: CaseIterable {
    var title: String {
        switch self {
        case .tasks: return "Tasks"
        case .timer: return "Timer"
        case .posts: return "Posts"
        case .stats: return "Stats"
        case .settings: return "Settings"
        }
    }
}

struct BarViewPreviews : PreviewProvider {
    
    struct Wrapper :  View {
        @State var selectedScreen : LandingScreen = .tasks;
        
        var body : some View {
            ZStack {
                Background()
                VStack {
                    TopBarView(selectedScreen: $selectedScreen)
                    Spacer()
                    BottomBarView(selectedScreen: $selectedScreen)
                }
            }
        }
    }
        
    
    static var previews : some View {
        Wrapper()
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
            .environmentObject(CurUser(credManager: CredManager()))
            .environmentObject(AppRouter())
            .environmentObject(NotificationManager())
    }
}
