import SwiftUI

struct HomeView: View {
    @EnvironmentObject var router: AppRouter;
    @EnvironmentObject var settings: Settings;
    @EnvironmentObject var sessions: Sessions;
    
    @State private var expandedTodo = false;
    @State private var selectedTodo = UUID();
    
    init() {
    }
    
    var body: some View {
        ZStack {
            Background()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            VStack {
                HStack {
                    Text(String(format: "%.1f IQ", sessions.getIQ()))
                      .font(Font.custom("Architects Daughter", size: 30))
                      .foregroundColor(ColorTokens.shade700)
                    Spacer()
                }
                Spacer()
                    .frame(maxHeight: 220)
                
                // display the timer selector
                CountdownSelectorView(timerParams: $settings.timerParam)
                
                OnboardingNextButton(text: "Start Cooking", onSelect: {
                    router.toTimerState(params: settings.timerParam, todoID: selectedTodo)
                })
                
                Spacer()
            }
            .safeAreaPadding(.all)
            
            Button(action: {
                if expandedTodo {
                    withAnimation {
                        expandedTodo = false;
                    }
                }
            }) {
                Rectangle()
                    .fill(expandedTodo ? Color.black.opacity(0.4) : .clear)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .allowsHitTesting(expandedTodo)
            .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                    .frame(maxHeight: 40)
                HStack {
                    TodoView(expanded: $expandedTodo, selectedTodo: $selectedTodo)
                    
                    Spacer()
                }
                if expandedTodo {
                    Spacer()
                        .frame(maxHeight: 100)
                } else {
                    Spacer()
                }
            }
            .safeAreaPadding(.all)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    ContentView()
        .environmentObject(AppRouter())
        .environmentObject(SettingsLoader.loadSettings())
        .environmentObject(ToDoLoader.getToDo())
        .environmentObject(SessionsLoader.loadSessions(onUpdate: {_ in }))
}
