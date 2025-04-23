import SwiftUI

struct HomeView: View {
    @EnvironmentObject var router: AppRouter;
    @State private var duration: TimeInterval;
    @State private var showingPicker = false;
    
    init() {
        switch Settings.loadSettings().timerType {
        case .countdown(let seconds):
            duration = Double(seconds);
        }
    }
    
    var body: some View {
        VStack {
            Spacer()  // Center Content

            Button (action: {
                showingPicker = true;
            }) {
                Text("\(formatTime(duration))")
                    .frame(width: 150, height: 150)
                    .padding()
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.orange)
                    .background(.gray)
                    .cornerRadius(10)
            }.sheet(isPresented: $showingPicker) {
                DurationPickerModal(duration: $duration)
            }
            
            // Circle button in the center of the screen
            Button(action: {
                // Action for the button (can navigate or do something)
                router.toTimerState(totTime: 20);
            }) {
                Text("Start Cooking")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .font(.headline)
                    .foregroundStyle(.white)
                    .background(.gray)
                    .cornerRadius(10)
            }

            Spacer()  // Push content up from the bottom
        }
        .edgesIgnoringSafeArea(.bottom)
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onChange(of: duration) {
            Settings.setTimerType(val:
                    .countdown(seconds: Int(duration.rounded())));
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(AppRouter());
    }
}

