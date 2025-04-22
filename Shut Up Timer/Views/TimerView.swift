import SwiftUI

struct TimerView: View {
    // holds the model
    @ObservedObject var timerViewModel: TimerViewModel;
    // access for page transitions
    @EnvironmentObject var router: AppRouter;
    @Environment(\.scenePhase) private var scenePhase;
    
    init(timerViewModel: TimerViewModel) {
        self.timerViewModel = timerViewModel
    }
    
    var body: some View {
        return VStack {
            // Timer at the top-middle of the screen
            Text("\(timerViewModel.timeLeft) / \(timerViewModel.totTime) seconds")
                .font(.system(size: 24))
                .fontWeight(.bold)
                .padding(.top, 50)  // Optional: adjust the top padding
                .frame(maxWidth: .infinity, alignment: .center)
            
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
        }
        .edgesIgnoringSafeArea(.bottom)  // Optional: makes the content fill the screen
        .onChange(of: timerViewModel.timeLeft) {
            // check if timer expires
            if(timerViewModel.timeLeft == 0) {
                timerViewModel.stopTimer();
                router.toTimerCompleted(totTime: timerViewModel.totTime);
            }
        }
        .onChange(of: scenePhase) {
            if scenePhase == .inactive {
                if timerViewModel.isRunning {
                    timerViewModel.stopTimer()
                    router.toTimerFailed(totTime: timerViewModel.totTime)
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
