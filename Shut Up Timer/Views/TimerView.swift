import SwiftUI

struct TimerView: View {
    @EnvironmentObject var router: AppRouter;
    
    init() {
    }
    
    var body: some View {
        let viewModel = router.timerViewModel;
        return VStack {
            // Timer at the top-middle of the screen
            Text("\(viewModel.timeLeft) / \(viewModel.totTime) seconds")
                .font(.system(size: 24))
                .fontWeight(.bold)
                .padding(.top, 50)  // Optional: adjust the top padding
                .frame(maxWidth: .infinity, alignment: .center)
            
            // Button to stop the timer
            Button(action: {
                if viewModel.isRunning {
                    viewModel.stopTimer()
                } else {
                    viewModel.startTimer()
                }
            }) {
                Text(viewModel.isRunning ? "Pause Timer" : "Start Timer")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding()
                    .background(viewModel.isRunning ? Color.red : Color.green)
                    .cornerRadius(10)
            }
            .padding(.top, 20)  // Optional: padding below the timer
            
            Spacer()  // Pushes everything up to leave space for Navbar
            
        }
        .edgesIgnoringSafeArea(.bottom)  // Optional: makes the content fill the screen
        
    }
    
}

#Preview {
    ContentView()
}
