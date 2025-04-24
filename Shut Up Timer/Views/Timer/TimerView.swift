import SwiftUI

struct TimerView: View {
    // holds the model
    @ObservedObject var timerViewModel: TimerViewModel;
    // access for page transitions
    @EnvironmentObject var router: AppRouter;
    @Environment(\.scenePhase) private var scenePhase;
    
    @State var todoExpanded: Bool = false;
    
    @State var quitExpanded: Bool = false;
    
    init(timerViewModel: TimerViewModel) {
        self.timerViewModel = timerViewModel;
        self.timerViewModel.startTimer()
    }
    
    func failTimer() {
        timerViewModel.stopTimer()
        router.toTimerFailed(totTime: timerViewModel.totTime)
    }
    
    var body: some View {
        return ZStack {
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
                    VStack {
                        Slider(onActivate: {
                            failTimer();
                            quitExpanded = false;
                        }, message: "Do you reall want to give up?")
                    }.padding()
                        .background(.white)
                }
            }
            .edgesIgnoringSafeArea(.bottom)  // Optional: makes the content fill the screen
            .padding()
            
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
                timerViewModel.stopTimer();
                router.toTimerCompleted(totTime: timerViewModel.totTime);
            }
        }	.onChange(of: scenePhase) {
            if scenePhase == .inactive {
                if timerViewModel.isRunning {
                    failTimer()
                }
            }
        }
    }
    
    
}

#Preview {
    let tvm = TimerViewModel()
    tvm.reset(totTime: 10)
    return TimerView(timerViewModel: tvm).environmentObject(AppRouter())
}
