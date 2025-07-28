import SwiftUI

enum LandingScreen {
    case tasksAndTimer
    case posts
    case stats
    case settings
    
    func screenName() -> String {
        switch self {
        case .tasksAndTimer: return "tasks and timer"
        case .posts: return "posts"
        case .stats: return "stats"
        case .settings: return "settings"
        }
    }
    
    static func from(_ from: LandingScreenOption) -> LandingScreen {
        switch from{
        case .tasks:
                .tasksAndTimer
        case .timer:
                .tasksAndTimer
        case .posts:
                .posts
        case .stats:
                .stats
        case .settings:
                .settings
        }
    }
}

struct LandingView: View {
    @State var selectedScreen: LandingScreen = .tasksAndTimer;
    // we will affect a task view when we select timer, so we keep track of the 'top screen' here
    @State var taskTopScreen: TaskView.TopTaskScreen = .beckon
    
    var isTimer: Bool {
        if selectedScreen == .tasksAndTimer, case .timer = taskTopScreen {
            return true
        }
        return false
    }
    
    var body: some View {
        ZStack {
            Background()
            
            // Top and bottom bars on top
            VStack(spacing: 0) {
                if isTimer {
                    HStack {
                        Button(action: {
                            withAnimation {
                                taskTopScreen = .beckon
                            }
                        }) {
                            Circle()
                                .fill(ColorTokens.red300)
                                .frame(width: 30, height: 30)
                                .overlay(
                                    Circle()
                                        .inset(by: 1)
                                        .stroke(.white, lineWidth: 2)
                                )
                                .overlay(
                                    Text("<")
                                        .font(FontTokens.architectsDaughter(size: 24))
                                        .foregroundColor(.white)
                                )
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 30)
                } else {
                    TopBarView()
                        .zIndex(5)
                }
                
                // Background content views
                ZStack {
                    TaskView(taskScreen: $taskTopScreen).tag(LandingScreenOption.tasks)
                        .opacity(selectedScreen == .tasksAndTimer ? 1 : 0)
                        .allowsHitTesting(selectedScreen == .tasksAndTimer)
                        .frame(maxHeight: .infinity)
                
                    SocialMediaView().tag(LandingScreenOption.posts)
                        .opacity(selectedScreen == .posts ? 1 : 0)
                        .allowsHitTesting(selectedScreen == .posts)
                
                    DisappointmentView().tag(LandingScreenOption.stats)
                        .opacity(selectedScreen == .stats ? 1 : 0)
                        .allowsHitTesting(selectedScreen == .stats)
                
                    ViewThatFits {
                        AccountView().tag(LandingScreenOption.settings)
                            .opacity(selectedScreen == .settings ? 1 : 0)
                            .allowsHitTesting(selectedScreen == .settings)
                        AccountView().tag(LandingScreenOption.settings)
                            .opacity(selectedScreen == .settings ? 1 : 0)
                            .allowsHitTesting(selectedScreen == .settings)
                            .frame(width: 350)
                    }
                }
                
                if isTimer {
                    Group {
                        Text("START THE GRIND")
                            .font(FontTokens.architectsDaughter(size: 24))
                            .foregroundColor(.white)
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                            .background(ColorTokens.red300)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .inset(by: 1)
                                    .stroke(.white, lineWidth: 2)
                            )
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom)
                } else {
                    BottomBarView(onScreenSelected: { screen in
                        let previousScreen = selectedScreen
                        withAnimation {
                            selectedScreen = LandingScreen.from(screen)
                            if screen == .timer {
                                taskTopScreen = .timer(todo: nil)
                            } else if screen == .tasks {
                                taskTopScreen = .beckon
                            }
                        }
                        if previousScreen != selectedScreen {
                            AnalyticsManager.shared.trackTabSwitch(from: previousScreen.screenName(), to: screen.screenName())
                            AnalyticsManager.shared.trackScreenView(screen.screenName())
                        }
                    })
                    .zIndex(5)
                }
            }
        }
    }
}
