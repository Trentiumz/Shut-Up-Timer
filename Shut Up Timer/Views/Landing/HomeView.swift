import SwiftUI

struct HomeView: View {
    @EnvironmentObject var router: AppRouter;
    
    var body: some View {
        VStack {
            Spacer()  // Center Content

            // Circle button in the center of the screen
            Button(action: {
                // Action for the button (can navigate or do something)
                router.toTimerState(totTime: 2);
            }) {
                Circle()
                    .fill(Color.blue)  // Circle color
                    .frame(width: 150, height: 150)  // Size of the circle
                    .overlay(
                        Text("Start Timer")
                            .foregroundColor(.white)
                            .font(.headline)
                    )
            }

            Spacer()  // Push content up from the bottom
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

