import SwiftUI

struct TimerCompletedView: View {
    @EnvironmentObject var router: AppRouter;
    private var timeLocked: Int;
    
    init(timeLocked: Int) {
        self.timeLocked = timeLocked;
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
                router.toHome();
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

#Preview {
    ContentView()
}
