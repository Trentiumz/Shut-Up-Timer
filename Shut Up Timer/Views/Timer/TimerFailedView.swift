import SwiftUI

struct TimerFailedView: View {
    @EnvironmentObject var router: AppRouter;
    private var timeLocked: TimeInterval;
    private var roast: String?;
    
    init(timeLocked: TimeInterval, roast: String? = nil) {
        self.timeLocked = timeLocked;
        self.roast = roast;
    }
    
    var body: some View {
        VStack {
            Spacer()
            Text("Idiot")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 50)
            
            Text("You failed to locked in for \(timeLocked) seconds!")
                .font(.title)
                .padding()
            
            if let roast = roast {
                Text("\(roast)")
                    .font(.largeTitle)
                    .padding()
            }             

            Button(action: {
                router.toHome();
            }) {
                Text("Go Home").font(.title)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(10);
            }
            
            Spacer() // Pushes the text towards the top
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Full-screen view
        .background(Color.red.opacity(0.2)) // Optional background color to make it more visible
        .cornerRadius(20)
        .ignoresSafeArea(.all)
    }
}

#Preview {
    TimerFailedView(timeLocked: 1800)
}
