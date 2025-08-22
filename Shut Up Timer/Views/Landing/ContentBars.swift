import SwiftUI;

struct TopBarView : View {
    @EnvironmentObject var curUser: CurUser
    @EnvironmentObject var sessions: SessionLoader;
    @EnvironmentObject var router: AppRouter;
    @EnvironmentObject var notificationManager: NotificationManager;
    
    enum TitleType {
        case normal
        case goBack(action: () -> Void)
    }
    var titleType: TitleType = .normal
    
    var body: some View {
        HStack{
            // App title on the left
            switch(titleType) {
            case .normal:
                Text("Zero Excuses >")
                    .font(FontTokens.architectsDaughter(size: 25))
                    .foregroundColor(.white)
            case .goBack(let action):
                Button(action: {
                    action()
                }) {
                    Text("< Back")
                        .font(FontTokens.architectsDaughter(size: 25))
                        .foregroundColor(.white)
                }
            }
            
            Spacer()
            
            HStack(alignment: .bottom) {
                // Icons on the right
                Button(action: {
                    AnalyticsManager.shared.trackScreenView("invite_friends")
                    router.toInviteFriends();
                }) {
                    Image(uiImage: FormattedImages.QrCode3)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 30)
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: {
                    AnalyticsManager.shared.trackScreenView("feedback")
                    router.toFeedbackView()
                }) {
                    Image(uiImage: FormattedImages.Image158)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 30)
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: {
                    AnalyticsManager.shared.trackScreenView("notifications")
                    router.toViewRequests()
                }) {
                    ZStack(alignment: .topTrailing) {
                        Image(uiImage: FormattedImages.Image157)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 30)
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
            }
        }
        .padding(.horizontal)
        .onAppear {
            curUser.refresh(animated: true)
        }
    }
}

enum LandingScreenOption {
    case tasks;
    case timer;
    case stats;
    case settings;
    
    func screenName() -> String {
        switch self {
        case .tasks: return "tasks"
        case .timer: return "timer"
        case .stats: return "stats"
        case .settings: return "settings"
        }
    }
}

struct BottomBarView : View {
    @EnvironmentObject var curUser: CurUser
    @Environment(\.managedObjectContext) private var viewContext
    
    let onScreenSelected: (LandingScreenOption) -> Void
    
    init(onScreenSelected: @escaping (LandingScreenOption) -> Void) {
        self.onScreenSelected = onScreenSelected
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
                    ForEach(LandingScreenOption.allCases, id: \.self) { tab in
                        Button(action: {
                            onScreenSelected(tab)
                        }) {
                            VStack(spacing: 0) {
                                Image(uiImage: imageForTab(tab))
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 48, height: 40, alignment: .bottom)
                                Text(tab.screenName())
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
        .padding(.top, 8)
    }
    
    private func imageForTab(_ tab: LandingScreenOption) -> UIImage {
        switch tab {
        case .tasks: return FormattedImages.Image145
        case .timer: return FormattedImages.Image147
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
}

extension LandingScreenOption: CaseIterable {
    var title: String {
        switch self {
        case .tasks: return "Tasks"
        case .timer: return "Timer"
        case .stats: return "Stats"
        case .settings: return "Settings"
        }
    }
}

struct BarViewPreviews : PreviewProvider {
    
    struct Wrapper :  View {
        @State var selectedScreen : LandingScreenOption = .tasks;
        
        var body : some View {
            ZStack {
                Background()
                VStack {
                    TopBarView()
                    Spacer()
                    BottomBarView(onScreenSelected: {_ in})
                }
            }
        }
    }
        
    
    static var previews : some View {
        Wrapper()
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
            .environmentObject(CurUser(credManager: CredManager(subscriptionManager: SubscriptionManager())))
            .environmentObject(AppRouter())
            .environmentObject(NotificationManager())
    }
}
