import SwiftUI

struct HomeView: View {
    @EnvironmentObject var router: AppRouter;
    @EnvironmentObject var settings: Settings;
    @EnvironmentObject var sessions: Sessions;
    
    @State private var expandedTodo = false
    @State private var selectedTodo = UUID();
    @Namespace private var todoNamespace
    
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
                    
                    // Collapsed TodoView (top right)
                    TodoView(expanded: $expandedTodo, selectedTodo: $selectedTodo, namespace: todoNamespace, isSource: !expandedTodo)
                        .matchedGeometryEffect(id: "todoView", in: todoNamespace, isSource: !expandedTodo)
                        .opacity(expandedTodo ? 0 : 1)
                        .allowsHitTesting(!expandedTodo)
                        .frame(width: 150, height: 180)
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
            .animation(TodoView.mainAnimation, value: expandedTodo)
            
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
            
            // Expanded TodoView (bottom left)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    TodoView(expanded: $expandedTodo, selectedTodo: $selectedTodo, namespace: todoNamespace, isSource: expandedTodo)
                        .matchedGeometryEffect(id: "todoView", in: todoNamespace, isSource: expandedTodo)
                        .opacity(expandedTodo ? 1 : 0)
                        .allowsHitTesting(expandedTodo)
                        .frame(width: 350, height: 500)
                    Spacer()
                }
                Spacer()
            }
            .safeAreaPadding(.all)
            .animation(TodoView.mainAnimation, value: expandedTodo)
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
