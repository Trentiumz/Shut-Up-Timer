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
    
    @Namespace private var todoNamespace
    
    init(timerModel: TimerViewModel) {
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
        
        var sessionResult = curSession.getSession(endTime: Date());
        sessionResult.roast = chosenRoast;
        router.toTimerFailed(session: sessionResult);
        sessions.sessions.append(sessionResult);
    }

    func successTransition() {
        TempSessionLoader.clearSession();
        timerViewModel.stopSession();
        
        let sessionResult = curSession.getSession(endTime: Date())
        router.toTimerCompleted(curSession: sessionResult);
        sessions.sessions.append(curSession.getSession(endTime: Date()));
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
    
    var body: some View {
        ZStack {
            Background()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            VStack {
                Spacer()
                HStack {
                    TodoView(expanded: $todoExpanded, selectedTodo: $selectedTodo, namespace: todoNamespace, isSource: !todoExpanded, isActive: !todoExpanded)
                        .matchedGeometryEffect(id: "todoView", in: todoNamespace, isSource: !todoExpanded)
                        .opacity(todoExpanded ? 0 : 1)
                        .frame(width: 150, height: 180)
                    Spacer()
                }
                .animation(TodoView.mainAnimation, value: todoExpanded)
                
                Text("\(Utils.formatTime(curSession.curParam.getTotTime()))")
                    .font(FontTokens.architectsDaughter(size: 60))
                    .foregroundStyle(ColorTokens.shade100)
                
                ViewThatFits {
                    PanFrame(0, 240, 240)
                        .padding(.horizontal)
                        .frame(width: 240, height: 160, alignment: .bottom)
                    PanFrame(0, 180, 180)
                        .padding(.horizontal)
                        .frame(width: 180, height: 100, alignment: .bottom)
                }
                
                Text("Farming IQ points...")
                    .font(FontTokens.architectsDaughter(size: 30))
                    .foregroundStyle(ColorTokens.shade100)
                
                ViewThatFits {
                    OnboardingNextButton(text: "Give Up", onSelect: {
                        quitExpanded = true;
                    })
                    OnboardingNextButton(text: "Give Up", onSelect: {
                        quitExpanded = true;
                    }, isSmall: true)
                }.sheet(isPresented: $quitExpanded) {
                    GiveUpSlider(onGiveUp: {
                        curSession.failTimer()
                        quitExpanded = false;
                    }, onCancel: {
                        quitExpanded = false
                    })
                }
            }
            .edgesIgnoringSafeArea(.bottom)
            .padding()
            
            Button(action: {
                if todoExpanded {
                    withAnimation {
                        todoExpanded = false;
                    }
                }
            }) {
                Rectangle()
                    .fill(todoExpanded ? Color.black.opacity(0.4) : .clear)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .allowsHitTesting(todoExpanded)
            .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                HStack {
                    Spacer();
                    TodoView(expanded: $todoExpanded, selectedTodo: $selectedTodo, namespace: todoNamespace, isSource: todoExpanded, isActive: todoExpanded)
                        .matchedGeometryEffect(id: "todoView", in: todoNamespace, isSource: todoExpanded)
                        .opacity(todoExpanded ? 1 : 0)
                        .frame(width: 350, height: 500)
                    Spacer()
                }
                Spacer()
            }
            .animation(TodoView.mainAnimation, value: todoExpanded)
        }
        .onAppear {
            // save starting state
            self.timerViewModel.saveTempSession();
            UIApplication.shared.isIdleTimerDisabled = true
            
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
        .onChange(of: scenePhase) { _ in
            if curSession.status == .inProgress {
                print("In progress scene change -> \(scenePhase)")
                if scenePhase == .background {
                    scheduleComeBackNotification();
                }
            }
            timerViewModel.updateScenePhase(scenePhase);
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
