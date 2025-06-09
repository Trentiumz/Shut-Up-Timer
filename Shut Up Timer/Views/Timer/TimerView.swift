import SwiftUI
import UserNotifications

struct TimerView: View {
    // holds the model
    @ObservedObject var timerViewModel: TimerViewModel;
    @ObservedObject var curSession: SessionInProgress; // this is exactly timerViewModel.curSession
    
    // access for page transitions
    @EnvironmentObject var router: AppRouter;
    @Environment(\.scenePhase) private var scenePhase;
    
    // whether the todo list is expanded
    @State var todoExpanded: Bool = false;
    @Binding var selectedTodo: UUID;
    
    // whether the modal for quitting is open
    @State var quitExpanded: Bool = false;

    @EnvironmentObject var sessions: Sessions;
    
    init(timerModel: TimerViewModel) {
        self.timerViewModel = timerModel;
        self.curSession = timerModel.curSession;
        self._selectedTodo = Binding(
            get: { timerModel.selectedTodo },
            set: { timerModel.selectedTodo = $0 }
        )
    }
    
    func failTimer() {
        TempSessionLoader.clearSession();
        timerViewModel.stopSession();
        let chosenRoast = getRandomRoast();
        
        router.toTimerFailed(timerModel: timerViewModel, roast: chosenRoast);
        sessions.sessions.append(curSession.getSession(endTime: Date()));
    }

    func succeedTimer() {
        TempSessionLoader.clearSession();

        timerViewModel.stopSession();
        router.toTimerCompleted(timerModel: timerViewModel);
        sessions.sessions.append(curSession.getSession(endTime: Date()));
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
                Text("\(formatTime(curSession.curParam.getTotTime()))")
                    .frame(width: 150, height: 150)
                    .padding()
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.orange)
                    .background(.gray)
                    .cornerRadius(10)
                
                Button(action: {
                    switch(curSession.status) {
                    case .inProgress:
                        timerViewModel.stopSession()
                        self.timerViewModel.saveTempSession();
                    case .paused:
                        timerViewModel.startSession()
                        self.timerViewModel.saveTempSession();
                    default: break;
                    }
                }) {
                    Text(curSession.status == .inProgress ? "Pause Timer" : "Start Timer")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding()
                        .background(curSession.status == .inProgress ? Color.red : Color.green)
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
                            curSession.failTimer();
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
            timerViewModel.startSession()
            self.timerViewModel.saveTempSession();
        }
        .onDisappear {
            // Allow screen to sleep when leaving view
            UIApplication.shared.isIdleTimerDisabled = false
            cancelNotifications()
            timerViewModel.destroy()
        }
        .onReceive(timerViewModel.$curSession) { val in
            if val.status == .succeeded {
                succeedTimer()
            } else if val.status == .failed {
                failTimer()
            }
        }
        .onChange(of: scenePhase) {
            timerViewModel.updateScenePhase(scenePhase);
        }
    }
}
