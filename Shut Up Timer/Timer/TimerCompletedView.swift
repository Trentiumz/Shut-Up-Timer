import SwiftUI

struct TimerCompletedView: View {
    private var timeLocked: Int

    // Constructor to initialize the time locked in
    init(timeLocked: Int) {
        self.timeLocked = timeLocked
    }
    
    var body: some View {
        VStack {
            Spacer()
            Text("Congratulations!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 50)
            
            Text("You locked in for \(timeLocked) seconds!")
                .font(.title)
                .padding()
            
            Button(action: {
                
            }) {
                Text("Go Home").font(.title)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(10);
            }
            
            Spacer() // Pushes the text towards the top
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Full-screen view
        .background(Color.green.opacity(0.2)) // Optional background color to make it more visible
        .cornerRadius(20)
        .ignoresSafeArea(.all)
    }
}

struct PTimerCompletedView_Previews: PreviewProvider {
    static var previews: some View {
        TimerCompletedView(timeLocked: 1800) // Preview with 1800 seconds locked
    }
}
