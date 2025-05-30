import SwiftUI
import UserNotifications

struct TimerView: View {
    // holds the model
    @ObservedObject var timerViewModel: TimerViewModel;
    // access for page transitions
    @EnvironmentObject var router: AppRouter;
    @Environment(\.scenePhase) private var scenePhase;
    
    // whether the todo list is expanded
    @State var todoExpanded: Bool = false;
    @Binding var selectedTodo: UUID;
    
    // whether the modal for quitting is open
    @State var quitExpanded: Bool = false;

    @EnvironmentObject var sessions: Sessions;
    
    // New state for background countdown
    @State private var lastOnScreen: Double = Date().timeIntervalSince1970
    @State private var checkerTimer: Timer? = nil
    
    init(timerViewModel: TimerViewModel, selectedTodo: Binding<UUID>) {
        self.timerViewModel = timerViewModel;
        self._selectedTodo = selectedTodo;
    }
    
    func failTimer() {
        TempSessionLoader.clearSession();

        timerViewModel.stopTimer()
        let chosenRoast = getRandomRoast();
        router.toTimerFailed(totTime: timerViewModel.totTime, roast: chosenRoast);
        sessions.sessions.append(
            SessionEntry(tasks: timerViewModel.tasks,
                         started: timerViewModel.startTime,
                         ended: Date(),
                         timeLocked: Double(timerViewModel.totTime - timerViewModel.timeLeft),
                         plannedTime: TimeInterval(timerViewModel.totTime),
                         success: false,
                         roast: chosenRoast));
    }

    func succeedTimer() {
        TempSessionLoader.clearSession();

        timerViewModel.stopTimer();
        router.toTimerCompleted(totTime: timerViewModel.totTime);
        sessions.sessions.append(
            SessionEntry(tasks: timerViewModel.tasks,
                         started: timerViewModel.startTime,
                         ended: Date(),
                         timeLocked: Double(timerViewModel.totTime - timerViewModel.timeLeft),
                         plannedTime: TimeInterval(timerViewModel.totTime),
                         success: true));
    }
    
    // Schedule local notification after 2 seconds of leaving
    func scheduleComeBackNotification() {
        let content = UNMutableNotificationContent()
        content.title = "HAIYAAAA"
        content.body = "Your friend’s IQ just lapped you. Come back."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        let request = UNNotificationRequest(identifier: "comeBackNotification", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }
    
    // Cancel scheduled notifications
    func cancelNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["comeBackNotification"])
    }
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                Text("\(formatTime(Double(timerViewModel.timeLeft)))")
                    .frame(width: 150, height: 150)
                    .padding()
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.orange)
                    .background(.gray)
                    .cornerRadius(10)
                
                Button(action: {
                    if timerViewModel.isRunning {
                        timerViewModel.stopTimer()
                        self.timerViewModel.saveTempSession();
                    } else {
                        timerViewModel.startTimer()
                        self.timerViewModel.saveTempSession();
                    }
                }) {
                    Text(timerViewModel.isRunning ? "Pause Timer" : "Start Timer")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding()
                        .background(timerViewModel.isRunning ? Color.red : Color.green)
                        .cornerRadius(10)
                }
                .padding(.top, 20)
                
                Button(action: {
                    quitExpanded = true;
                }) {
                    Text("Give up")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.gray)
                        .cornerRadius(10)
                }
                .sheet(isPresented: $quitExpanded) {
                    VStack {
                        Slider(onActivate: {
                            failTimer();
                            quitExpanded = false;
                        }, message: "Do you really want to give up?")
                    }
                    .padding()
                    .background(.white)
                }
            }
            .edgesIgnoringSafeArea(.bottom)
            .padding()
            
            VStack {
                HStack {
                    TodoView(expanded: $todoExpanded, selectedTodo: $selectedTodo)
                    Spacer()
                }
                Spacer()
            }
        }
        .onAppear {
            // Keep screen awake
            UIApplication.shared.isIdleTimerDisabled = true
            self.timerViewModel.startTimer()
            checkerTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                if timerViewModel.isRunning {
                    let currentTime = Date().timeIntervalSince1970
                    if currentTime - lastOnScreen > 20 {
                        failTimer()
                    }
                    if scenePhase == .active {
                        lastOnScreen = Date().timeIntervalSince1970
                    }
                } else {
                    checkerTimer?.invalidate()
                    checkerTimer = nil
                }
            }
            
            self.timerViewModel.saveTempSession();
        }
        .onDisappear {
            // Allow screen to sleep when leaving view
            UIApplication.shared.isIdleTimerDisabled = false
            cancelNotifications()
            checkerTimer?.invalidate()
            checkerTimer = nil
        }
        .onChange(of: timerViewModel.timeLeft) {
            if timerViewModel.timeLeft == 0 {
                succeedTimer()
            }
        }
        .onChange(of: scenePhase) {
            switch scenePhase {
            case .active:
                // User came back, cancel fail timer & notifications
                cancelNotifications()
                self.timerViewModel.saveTempSession();
                
            case .inactive:
                // User left app, start 20 second fail timer and schedule notification after 2 seconds
                if timerViewModel.isRunning {
                    scheduleComeBackNotification()
                }
                self.timerViewModel.saveTempSession();
                
            case .background:
                // Similar to inactive, can also handle if needed
                self.timerViewModel.saveTempSession();
                
            @unknown default:
                break
            }
        }
    }
}
