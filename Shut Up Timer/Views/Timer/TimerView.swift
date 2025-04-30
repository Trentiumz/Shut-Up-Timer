import SwiftUI

struct TimerView: View {
    // holds the model
    @ObservedObject var timerViewModel: TimerViewModel;
    // access for page transitions
    @EnvironmentObject var router: AppRouter;
    @Environment(\.scenePhase) private var scenePhase;
    
    // whether the todo list is expanded
    @State var todoExpanded: Bool = false;
    
    // whether the modal for quitting is open
    @State var quitExpanded: Bool = false;

    @EnvironmentObject var sessions: Sessions;
    
    init(timerViewModel: TimerViewModel) {
        self.timerViewModel = timerViewModel;
    }
    
    // go to timer failed slide
    func failTimer() {
        timerViewModel.stopTimer()
        router.toTimerFailed(totTime: timerViewModel.totTime)
        sessions.sessions.append(
            SessionEntry(todoID: timerViewModel.todoID,
                         started: timerViewModel.startTime,
                         ended: Date(),
                         timeLocked: Double(timerViewModel.totTime - timerViewModel.timeLeft),
                         success: false));
    }

    func succeedTimer() {
        timerViewModel.stopTimer();
        router.toTimerCompleted(totTime: timerViewModel.totTime);
        sessions.sessions.append(
            SessionEntry(todoID: timerViewModel.todoID,
                         started: timerViewModel.startTime,
                         ended: Date(),
                         timeLocked: Double(timerViewModel.totTime - timerViewModel.timeLeft),
                         success: true));
    }
    
    var body: some View {
        return ZStack {
            // main content of timer
            VStack {
                Spacer()
                // Timer at the top-middle of the screen
                Text("\(formatTime(Double(timerViewModel.timeLeft)))")
                    .frame(width: 150, height: 150)
                    .padding()
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.orange)
                    .background(.gray)
                    .cornerRadius(10)
                
                // Button to stop the timer
                Button(action: {
                    if timerViewModel.isRunning {
                        timerViewModel.stopTimer()
                    } else {
                        timerViewModel.startTimer()
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
                
                // button to give up
                Button(action: {
                    quitExpanded = true;
                }) {
                    Text("Give up")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.gray)
                        .cornerRadius(10)
                }.sheet(isPresented: $quitExpanded) {
                    // when the sheet is open, they're tryna quit :(
                    VStack {
                        Slider(onActivate: {
                            failTimer();
                            quitExpanded = false;
                        }, message: "Do you really want to give up?")
                    }.padding()
                        .background(.white)
                }
            }
            .edgesIgnoringSafeArea(.bottom)  // Optional: makes the content fill the screen
            .padding()
            
            // todo list item
            VStack {
                HStack {
                    TodoView(expanded: $todoExpanded)
                    Spacer()
                }
                Spacer()
            }
        }.onChange(of: timerViewModel.timeLeft) {
            // check if timer expires
            if(timerViewModel.timeLeft == 0) {
                succeedTimer();
            }
        }.onChange(of: scenePhase) {
            // fail on leaving
            if scenePhase == .inactive {
                if timerViewModel.isRunning {
                    failTimer()
                }
            }
        }.onAppear() {
            // start timer when appear
            self.timerViewModel.startTimer();
        }
    }
    
    
}

#Preview {
    let tvm = TimerViewModel()
    tvm.reset(totTime: 10, startTime: Date(), todoID: UUID())
    return TimerView(timerViewModel: tvm).environmentObject(AppRouter())
}
