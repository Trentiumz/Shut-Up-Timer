import SwiftUI

struct TimerView: View {
    @ObservedObject var timerViewModel = TimerViewModel(totTime: 5);
    @EnvironmentObject var appState: AppStateModel;
    
    init() {
        
    }
    
    var body: some View {
        VStack {
            // Timer at the top-middle of the screen
            Text("\(timerViewModel.timeLeft) / \(timerViewModel.totTime) seconds")
                .font(.system(size: 24))
                .fontWeight(.bold)
                .padding(.top, 50)  // Optional: adjust the top padding
                .frame(maxWidth: .infinity, alignment: .center)
            
            // Button to stop the timer
            Button(action: {
                if timerViewModel.timerRunning {
                    timerViewModel.pauseTimer()
                } else {
                    timerViewModel.startTimer()
                }
            }) {
                Text(timerViewModel.timerRunning ? "Pause Timer" : "Start Timer")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding()
                    .background(timerViewModel.timerRunning ? Color.red : Color.green)
                    .cornerRadius(10)
            }
            .padding(.top, 20)  // Optional: padding below the timer
            
            Spacer()  // Pushes everything up to leave space for Navbar
            
            // Navbar at the bottom
            Navbar()
                .edgesIgnoringSafeArea(.bottom)  // Ensures it's at the bottom of the screen
        }
        .edgesIgnoringSafeArea(.bottom)  // Optional: makes the content fill the screen
        .onAppear{
            timerViewModel.onFinish = {
                appState.changeState(state: .timerCompleted(seconds: 5));
                print(appState)
            }
        }
    }

}

#Preview {
    ContentView().environmentObject(AppStateModel(curState: .home))
}
