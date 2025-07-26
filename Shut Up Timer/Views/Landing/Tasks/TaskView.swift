import SwiftUI
import CoreData

struct TaskView: View {
    enum TopTaskScreen {
        case beckon
        case addGoal
        case addTask
    }
    
    @State private var taskScreen: TopTaskScreen = .beckon
    @Environment(\.managedObjectContext) private var viewContext
    
    private let rightwardAnimation = AnyTransition.asymmetric(
        insertion: AnyTransition.move(edge: .trailing),
        removal: AnyTransition.move(edge: .leading)
    )
    
    var body: some View {
        VStack(spacing: 15) {
            switch(taskScreen) {
            case .addGoal:
                GoalAddView { temporaryGoal in
                    let success = addGoal(temporaryGoal)
                    if success {
                        withAnimation {
                            taskScreen = .beckon
                        }
                    }
                }
                .padding()
                .transition(rightwardAnimation)
            case .beckon:
                TodoBeckonView()
                    .transition(rightwardAnimation)
            case .addTask:
                TaskAddView(
                    onTaskAdd: { tasks in
                        let success = addTasks(tasks)
                        if success {
                            withAnimation {
                                taskScreen = .beckon
                            }
                        }
                    }
                )
                .padding()
                .transition(rightwardAnimation)
            }
            TaskListView(
                onAddGoal: {
                    withAnimation {
                        taskScreen = .addGoal
                    }
                },
                onAddTask: {
                    withAnimation {
                        taskScreen = .addTask
                    }
                }
            )
            .frame(maxHeight: 400)
            .padding(.horizontal, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .coordinateSpace(name: "todo-card")
    }
    
    private func addGoal(_ temporaryGoal: TemporaryGoal) -> Bool {
        // get the minimum order value
        let fetchRequest = Goal.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
        fetchRequest.fetchLimit = 1
        fetchRequest.propertiesToFetch = ["order"]
        fetchRequest.resultType = .managedObjectResultType
        
        do {
            var minVal: Int16 = 0;
            if let result = try viewContext.fetch(fetchRequest).first {
                minVal = result.value(forKey: "order") as? Int16 ?? 0;
            }
            
            viewContext.reset()
            // add the goal
            let goal = Goal(context: viewContext)
            goal.id = UUID()
            goal.created = Date()
            goal.goal = temporaryGoal.name
            goal.iqGoal = temporaryGoal.iqGoal
            goal.iqCurrent = 0.0
            goal.redeemed = false
            goal.color = colorToHexString(temporaryGoal.color)
            goal.order = minVal - 1
            
            try viewContext.save()
            return true;
        } catch {
            print("Failed to fetch min value: \(error)")
            viewContext.reset()
            return false;
        }
    }
    
    private func addTasks(_ temporaryTasks: [TemporaryTask]) -> Bool {
        do {
            let currentDate = Date()
            
            // Create Todo entities from TemporaryTask array
            for (index, tempTask) in temporaryTasks.enumerated() {
                let todo = Todo(context: viewContext)
                todo.id = UUID()
                todo.todo = tempTask.name.trimmingCharacters(in: .whitespacesAndNewlines)
                todo.active = true
                todo.completed = false
                todo.created = currentDate.addingTimeInterval(Double(index)) // Slight offset for ordering
                todo.order = Int16(index) // Set order based on position in array
                todo.goal = tempTask.goal // Link to goal if specified
            }
            
            try viewContext.save()
            return true
        } catch {
            print("Failed to save new tasks: \(error)")
            viewContext.reset()
            return false
        }
    }
}

#Preview {
    TaskView()
        .environmentObject(AppRouter())
        .environmentObject(SettingsLoader.loadSettings())
} 
