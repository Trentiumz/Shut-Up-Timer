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
            
            VStack(spacing: 0) {
                HStack(alignment: .top) {
                    Text(String(format: "%.1f IQ", sessions.getIQ()))
                        .font(Font.custom("Architects Daughter", size: 30))
                        .foregroundColor(ColorTokens.shade700)
                    Spacer()
                    
                    if !expandedTodo {
                        TodoView(expanded: $expandedTodo, selectedTodo: $selectedTodo)
                            .transition(.opacity)
                    } else {
                        Rectangle()
                            .fill(.clear)
                            .frame(width: 120, height: 160)
                    }
                }.padding(.horizontal, 10)
                
                Spacer()
                
                // display the timer selector
                CountdownSelectorView(timerParams: $settings.timerParam)
                
                Spacer()
                
                OnboardingNextButton(text: "Start Cooking", onSelect: {
                    router.toTimerState(params: settings.timerParam, todoID: selectedTodo)
                })
                
                Spacer()
                    .frame(maxHeight: 10)
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
                HStack {
                    if expandedTodo {
                        TodoView(expanded: $expandedTodo, selectedTodo: $selectedTodo)
                            .transition(.opacity)
                    }
                    
                    Spacer()
                }
                Spacer()
            }
            .safeAreaPadding(.all)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all)
        .coordinateSpace(name: "todo-card")
    }
}

#Preview {
    HomeView()
        .environmentObject(AppRouter())
        .environmentObject(SettingsLoader.loadSettings())
        .environmentObject(ToDoLoader.getToDo())
        .environmentObject(SessionsLoader.loadSessions(onUpdate: {_ in }))
}
