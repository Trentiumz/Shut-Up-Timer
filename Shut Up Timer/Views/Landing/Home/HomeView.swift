import SwiftUI

// TODO: Sync up settings (particularly for duration) between the different parts (central settings object??)

struct HomeView: View {
    @EnvironmentObject var router: AppRouter;
    @EnvironmentObject var settings: Settings;
    
    @State private var expandedTodo = false;
    @State private var selectedTodo = UUID();
    
    init() {
    }
    
    var body: some View {
        VStack {
            ZStack {
                VStack {
                    Spacer().layoutPriority(0.5)
                    
                    // display the timer selector
                    CountdownSelectorView(timerParams: $settings.timerParam)
                    
                    // Circle button in the center of the screen
                    Button(action: {
                        // Action for the button (can navigate or do something)
                        router.toTimerState(params: settings.timerParam, todoID: selectedTodo);
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
                        TodoView(expanded: $expandedTodo, selectedTodo: $selectedTodo)
                            
                        Spacer()
                    }
                    Spacer()
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(AppRouter());
    }
}

