import SwiftUI

struct HomeView: View {
    @EnvironmentObject var router: AppRouter;
    
    // timer parameters
    @State private var timerParams: TimerParam;
    
    @State private var expandedTodo = false;
    
    init() {
        timerParams = Settings.loadSettings().timerParam
    }
    
    var body: some View {
        VStack {
            ZStack {
                VStack {
                    Spacer().layoutPriority(0.5)
                    
                    // display the timer selector
                    switch timerParams {
                    case .countdown(let seconds):
                        CountdownSelectorView(initialDuation: Double(seconds), timerParams: $timerParams)
                    }
                    
                    // Circle button in the center of the screen
                    Button(action: {
                        // Action for the button (can navigate or do something)
                        router.toTimerState(params: timerParams);
                    }) {
                        Text("Start Cooking")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .font(.headline)
                            .foregroundStyle(.white)
                            .background(.gray)
                            .cornerRadius(10)
                    }
                    Spacer().layoutPriority(0.4)
                }.overlay {
                    // if todo is in focus, the blur this
                    if expandedTodo {
                        Color.white.opacity(0.4)
                    }
                }
                
                // todo list at the top
                VStack {
                    HStack {
                        TodoView(expanded: $expandedTodo)
                            
                        Spacer()
                    }
                    Spacer()
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onChange(of: timerParams) {
            Settings.setTimerType(val: timerParams);
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(AppRouter());
    }
}

