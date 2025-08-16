import SwiftUI

enum LandingScreen: Equatable {
    case tasksAndTimer
//    case posts
    case stats(display: StatsView.StatDisplay)
    case settings
    
    func screenName() -> String {
        switch self {
        case .tasksAndTimer: return "tasks and timer"
//        case .posts: return "posts"
        case .stats: return "stats"
        case .settings: return "settings"
        }
    }
    
    func updateOnClick(_ from: LandingScreenOption) -> LandingScreen {
        switch from{
        case .tasks:
                .tasksAndTimer
        case .timer:
                .tasksAndTimer
//        case .posts:
//                .posts
        case .stats:
            switch(self) {
            case .stats(let display):
                    .stats(display: display)
            default:
                    .stats(display: .stats)
            }
        case .settings:
                .settings
        }
    }
}

struct LandingView: View {
    @State var selectedScreen: LandingScreen = .tasksAndTimer;
    // we will affect a task view when we select timer, so we keep track of the 'top screen' here
    // In this case, .other = .timer
    @State var taskTopScreen: TopTaskScreen = .start
    @State var taskTimerSelectorTodo: Todo? = nil
    
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var settings: Settings
    @EnvironmentObject var liveActivityManager: LiveActivityManager
    
    var isTimer: Bool {
        if selectedScreen == .tasksAndTimer, case .other = taskTopScreen {
            return true
        }
        return false
    }
    var isStats: Bool {
        if case .stats = selectedScreen {
            return true;
        }
        return false
    }
    
    var taskSelectableBehavior: TaskSelectable? {
        switch(taskTopScreen) {
        case .other:
            TaskSelectable(title: "select", onSelect: { todo in
                withAnimation {
                    taskTopScreen = .other
                    taskTimerSelectorTodo = todo
                }
            })
        default:
            TaskSelectable(title: "lock in", onSelect: { todo in
                withAnimation {
                    taskTopScreen = .other
                    taskTimerSelectorTodo = todo
                }
            })
        }
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
                                taskTopScreen = .start
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
                    let titleType: TopBarView.TitleType = switch(selectedScreen) {
                    case .stats(.album):
                            .goBack(action: {
                                withAnimation {
                                    selectedScreen = .stats(display: .stats)
                                }
                            })
                    default:
                            .normal
                    }
                    TopBarView(titleType: titleType)
                        .zIndex(5)
                }
                
                // Background content views
                ZStack {
                    TaskView<TodoBeckonView, TimerPreStartSelector>(taskScreen: $taskTopScreen, startView: { TodoBeckonView() }, otherView: { TimerPreStartSelector(todo: taskTimerSelectorTodo)}).tag(LandingScreenOption.tasks)
                        .opacity(selectedScreen == .tasksAndTimer ? 1 : 0)
                        .allowsHitTesting(selectedScreen == .tasksAndTimer)
                        .frame(maxHeight: .infinity)
                        .environment(\.taskSelectable, taskSelectableBehavior)
                
//                    SocialMediaView().tag(LandingScreenOption.posts)
//                        .opacity(selectedScreen == .posts ? 1 : 0)
//                        .allowsHitTesting(selectedScreen == .posts)
//                
                    StatsView(statDisplay: Binding<StatsView.StatDisplay>(
                        get: { switch(selectedScreen) {
                        case .stats(let display):
                            display
                        default:
                                .stats
                        }},
                        set: {
                            selectedScreen = .stats(display: $0)
                        }
                    )).tag(LandingScreenOption.stats)
                        .opacity(isStats ? 1 : 0)
                        .allowsHitTesting(isStats)
                
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
                        Button(action: {
                            let managerType: TimerManagerType = settings.difficulty == .asian ? .noLeave : .appBlock
                            router.toTimerState(params: settings.timerParam, todoID: taskTimerSelectorTodo?.id ?? UUID(), managerType: managerType, liveActivityManager: liveActivityManager)
                        }) {
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
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom)
                } else {
                    BottomBarView(onScreenSelected: { screen in
                        let previousScreen = selectedScreen
                        withAnimation {
                            selectedScreen = selectedScreen.updateOnClick(screen)
                            if screen == .timer {
                                taskTopScreen = .other
                                taskTimerSelectorTodo = nil
                            } else if screen == .tasks {
                                taskTopScreen = .start
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
