import SwiftUI

struct TimerView: View {
    @ObservedObject var timerViewModel: TimerViewModel;
    @EnvironmentObject var router: AppRouter;
    
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
            .padding(.top, 20)  // Optional: padding below the timer
            
            Spacer()  // Pushes everything up to leave space for Navbar
            
        }
        .edgesIgnoringSafeArea(.bottom)  // Optional: makes the content fill the screen
        .onChange(of: timerViewModel.timeLeft) {
            if(timerViewModel.timeLeft == 0) {
                router.toTimerCompleted(totTime: timerViewModel.totTime);
            }
        }
    }
    
}

#Preview {
    ContentView()
}
