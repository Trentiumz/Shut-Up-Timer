import SwiftUI
import UserNotifications
import CoreData

enum TimerScreenState {
    case mainTimer
    case taskSelection
    case giveup
}

struct TimerView<Manager: CurSessionManager>: View {
    // holds the model
    @ObservedObject var timerViewModel: TimerViewModel<Manager>;
    @ObservedObject var curSession: Manager; // this is exactly timerViewModel.curSession
    
    // access for page transitions
    @EnvironmentObject var router: AppRouter;
    @EnvironmentObject var liveActivityManager: LiveActivityManager
    @Environment(\.scenePhase) private var scenePhase;
    @Environment(\.managedObjectContext) private var viewContext
    
    // Screen state management
    @State private var prevScreen: TimerScreenState? = nil
    @State private var currentScreen: TimerScreenState = .mainTimer
    
    // Selected todo state
    @State private var selectedTodoObject: Todo?
    @Binding var selectedTodo: UUID;

    @EnvironmentObject var sessions: SessionLoader;
    
    @Namespace private var sharedTimerNamespace
    
    init(timerModel: TimerViewModel<Manager>) {
        self.timerViewModel = timerModel;
        self.curSession = timerModel.curSession;
        self._selectedTodo = Binding(
            get: { timerModel.selectedTodo },
            set: { timerModel.selectedTodo = $0 }
        )
    }
    
    func failureTransition() {
        TempSessionLoader.clearSession();
        timerViewModel.stopSession();
        let chosenRoast = getRandomRoast();
        
        var tempSession = curSession.getSession(endTime: Date());
        tempSession.roast = chosenRoast;
        
        // Track timer failure analytics
        let timerType = curSession.managerType == .noLeave ? "no_leave" : "app_block"
        let plannedDuration = tempSession.plannedTime
        let actualDuration = tempSession.timeLocked
        AnalyticsManager.shared.trackTimerFailed(
            type: timerType,
            duration: plannedDuration,
            failedAfter: actualDuration,
            reason: "user_quit"
        )
        
        sessions.addSession(tempSession)
        liveActivityManager.userFinishedStudying();
        router.toTimerFailed(session: tempSession);
    }

    func successTransition() {
        TempSessionLoader.clearSession();
        timerViewModel.stopSession();
        
        let tempSession = curSession.getSession(endTime: Date())
        
        // Track timer completion analytics
        let timerType = curSession.managerType == .noLeave ? "no_leave" : "app_block"
        let plannedDuration = tempSession.plannedTime
        let actualDuration = tempSession.timeLocked
        AnalyticsManager.shared.trackTimerComplete(
            type: timerType,
            duration: plannedDuration,
            actualDuration: actualDuration
        )
        
        sessions.addSession(tempSession)
        liveActivityManager.userFinishedStudying();
        router.toTimerCompleted(curSession: tempSession);
    }
    
    func handleStatus(_ curStatus: SessionStatus) {
        if curStatus == .succeeded {
            successTransition()
        } else if curStatus == .failed {
            failureTransition()
        }
    }
    
    // Schedule local notification after 2 seconds of leaving
    func scheduleComeBackNotification() {
        let content = UNMutableNotificationContent()
        content.title = "HAIYAAAA"
        content.body = "Your friend's IQ just lapped you. Come back."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        let request = UNNotificationRequest(identifier: "comeBackNotification", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }
    
    // Cancel scheduled notifications
    func cancelNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["comeBackNotification"])
    }
    
    // Load selected todo from UUID
    private func loadSelectedTodo() {
        let request: NSFetchRequest<Todo> = Todo.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", selectedTodo as CVarArg)
        
        do {
            let results = try viewContext.fetch(request)
            selectedTodoObject = results.first
        } catch {
            print("Failed to fetch selected todo: \(error)")
            selectedTodoObject = nil
        }
    }
    
    var body: some View {
        ZStack {
            Background()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Main Timer Screen
            Group {
                TimerMainScreen(
                    timerParam: curSession.curParam,
                    iqChange: curSession.iqChange,
                    selectedTodo: selectedTodoObject,
                    onTaskTitleTap: {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            currentScreen = .taskSelection
                        }
                    },
                    onGiveUpTap: {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            prevScreen = .mainTimer
                            currentScreen = .giveup
                        }
                    },
                    namespace: sharedTimerNamespace,
                    isSource: currentScreen == .mainTimer
                )
                .opacity(currentScreen == .mainTimer ? 1 : 0)
                .allowsHitTesting(currentScreen == .mainTimer)
            }
            .transition(.asymmetric(
                insertion: .move(edge: .leading).combined(with: .opacity),
                removal: .move(edge: .trailing).combined(with: .opacity)
            ))
            
            // Task Selection Screen
            Group {
                TimerTaskSelectionScreen(
                    timerParam: curSession.curParam,
                    selectedTodo: selectedTodoObject,
                    onBack: {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            currentScreen = .mainTimer
                        }
                    },
                    onTaskSelected: { todo in
                        selectedTodo = todo.id ?? UUID()
                        selectedTodoObject = todo
                        withAnimation(.easeInOut(duration: 0.4)) {
                            currentScreen = .mainTimer
                        }
                    },
                    namespace: sharedTimerNamespace,
                    isSource: currentScreen == .taskSelection
                )
                .opacity(currentScreen == .taskSelection ? 1 : 0)
                .allowsHitTesting(currentScreen == .taskSelection)
            }
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            ))
            
            // Give up Screen
            Group {
                GiveUpPromptView(onNo: {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        currentScreen = prevScreen ?? .mainTimer
                    }
                }, onYes: {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        curSession.failTimer()
                        currentScreen = prevScreen ?? .mainTimer
                    }
                })
                .opacity(currentScreen == .giveup ? 1 : 0)
                .allowsHitTesting(currentScreen == .giveup)
            }
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            ))
        }
        .onAppear {
            // Load the selected todo object from UUID
            loadSelectedTodo()
            
            // save starting state
            self.timerViewModel.saveTempSession();
            UIApplication.shared.isIdleTimerDisabled = true
            
            // Track timer start analytics
            let timerType = curSession.managerType == .noLeave ? "no_leave" : "app_block"
            let duration = curSession.curParam.getTotTime()
            let sessionType = curSession.managerType.rawValue
            AnalyticsManager.shared.trackTimerStart(
                type: timerType,
                duration: duration,
                sessionType: sessionType,
                roastLevel: "N/A"
            )
            
            // begin the session & initial updates (for continuation)
            timerViewModel.startSession()
            curSession.tick(phase: .active)
            handleStatus(curSession.status);
        }
        .onDisappear {
            // Allow screen to sleep when leaving view
            UIApplication.shared.isIdleTimerDisabled = false
            cancelNotifications()
            timerViewModel.destroy()
        }
        .onChange(of: curSession.status) { newVal in
            handleStatus(newVal);
        }
        .onChange(of: scenePhase) { newVal in
            print("In progress scene change -> \(newVal), current status is \(curSession.status)")
            if curSession.status == .inProgress {
                if newVal == .background && curSession.managerType == .noLeave {
                    scheduleComeBackNotification();
                }
            }
            timerViewModel.updateScenePhase(newVal);
        }
        .onChange(of: selectedTodo) { _ in
            loadSelectedTodo()
        }
    }
}

struct GiveUpSlider : View {
    var onGiveUp: () -> Void;
    var onCancel: () -> Void;
    
    var body : some View {
        ZStack {
            Background()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            TodoPaper(width: 400)
            VStack {
                Spacer()
                Text("Are you sure you want to give up?")
                  .font(Font.custom("Architects Daughter", size: 30))
                  .foregroundColor(ColorTokens.shade700)
                  .frame(width: 269, alignment: .topLeading)
                Spacer()
                    .frame(maxHeight: 70)
                Slider(onActivate: onGiveUp, message: "Slide to give up")
                Spacer()
                    .frame(maxHeight: 40)
                Button(action: onCancel){
                    Rectangle()
                      .foregroundColor(.clear)
                      .frame(width: 54, height: 54)
                      .background(ColorTokens.shade300)
                      .cornerRadius(10)
                      .overlay(
                        RoundedRectangle(cornerRadius: 10)
                          .inset(by: 1)
                          .stroke(ColorTokens.shade700, lineWidth: 2)
                      )
                      .overlay(
                        Text("x")
                          .font(Font.custom("Architects Daughter", size: 50))
                          .multilineTextAlignment(.center)
                          .foregroundColor(ColorTokens.shade700)
                      )
                }
                Spacer()
                    .frame(maxHeight: 80)
            }.frame(maxHeight: 600)
        }
    }
}

#Preview {
    GiveUpSlider(onGiveUp: {}, onCancel: {})
}
