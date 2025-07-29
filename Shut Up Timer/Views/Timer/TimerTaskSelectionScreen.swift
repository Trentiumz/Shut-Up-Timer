import SwiftUI
import CoreData

struct TimerTaskSelectionScreen: View {
    let timerParam: TimerParam
    var selectedTodo: Todo?
    let onBack: () -> Void
    let onTaskSelected: (Todo) -> Void
    let namespace: Namespace.ID
    let isSource: Bool
    
    @State private var taskScreen: TopTaskScreen = .start
    
    var taskSelectableBehavior: TaskSelectable {
        TaskSelectable(title: "select", onSelect: { todo in
            onTaskSelected(todo)
        })
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Back button
            if isSource {
                HStack {
                    Button(action: onBack) {
                        Circle()
                            .fill(ColorTokens.red300)
                            .frame(width: 30, height: 30)
                            .overlay(
                                Circle()
                                    .inset(by: 1)
                                    .stroke(.white, lineWidth: 2)
                            )
                            .overlay(
                                Text("<")
                                    .font(FontTokens.architectsDaughter(size: 24))
                                    .foregroundColor(.white)
                            )
                    }
                    Spacer()
                }
                .padding(.horizontal, 30)
                .padding(.top, 20)
                .transition(.move(edge: .top))
            }
            
            Spacer()
            
            // Task selection view
            TaskView<SharedTimerDisplay, EmptyView>(
                taskScreen: $taskScreen,
                startView: { SharedTimerDisplay(timerParam: timerParam, namespace: namespace, isSource: isSource) },
                otherView: { EmptyView() }
            )
            .environment(\.taskSelectable, taskSelectableBehavior)
            .transition(.move(edge: .bottom))
        }
    }
}

struct TimerTaskSelectionScreenPreview: PreviewProvider {
    struct Wrapper: View {
        @Namespace var namespace
        
        var body: some View {
            ZStack {
                Background()
                TimerTaskSelectionScreen(
                    timerParam: .countdown(seconds: 1920), // 32 minutes
                    selectedTodo: nil,
                    onBack: { },
                    onTaskSelected: { _ in },
                    namespace: namespace,
                    isSource: false
                )
            }
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
        }
    }
    
    static var previews: some View {
        Wrapper()
    }
} 
