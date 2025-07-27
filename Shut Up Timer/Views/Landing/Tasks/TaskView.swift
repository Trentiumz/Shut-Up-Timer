import SwiftUI
import CoreData

struct TaskView: View {
    enum TopTaskScreen {
        case beckon
        case addGoal
        case addTask
        case redeem(goal: Goal)
    }
    
    @State private var taskScreen: TopTaskScreen = .beckon
    @Environment(\.managedObjectContext) private var viewContext
    
    @FocusState var todoTitleEditID: UUID?
    @State private var displayTop: Bool = true
    
    private let rightwardAnimation = AnyTransition.asymmetric(
        insertion: AnyTransition.move(edge: .trailing),
        removal: AnyTransition.move(edge: .leading)
    )
    
    var body: some View {
        VStack {
            if displayTop {
                Spacer()
                switch(taskScreen) {
                case .addGoal:
                    GoalAddView { temporaryGoal in
                        withAnimation {
                            let success = addGoal(temporaryGoal)
                            if success {
                                taskScreen = .beckon
                            }
                        }
                    } onCancel: {
                        withAnimation {
                            taskScreen = .beckon
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
                            withAnimation {
                                let success = addTasks(tasks)
                                if success {
                                    taskScreen = .beckon
                                }
                            }
                        },
                        onCancel: {
                            withAnimation {
                                taskScreen = .beckon
                            }
                        }
                    )
                    .padding()
                    .transition(rightwardAnimation)
                case .redeem(let goal):
                    GoalRedeemView(
                        goal: goal,
                        onRedeem: { goal in
                            do {
                                try withAnimation {
                                    goal.redeemed = true
                                    try viewContext.save()
                                    taskScreen = .beckon
                                }
                            } catch {
                                print("Error redeeming goal: \(error)")
                            }
                        },
                        onCancel: {
                            withAnimation {
                                taskScreen = .beckon
                            }
                        }
                    )
                    .padding()
                    .transition(rightwardAnimation)
                }
            }
            
            Spacer()
                .frame(maxHeight: 15)
            
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
                },
                onRedeem: { goal in
                    withAnimation {
                        taskScreen = .redeem(goal: goal)
                    }
                },
                todoTitleEditID: $todoTitleEditID
            )
            .frame(maxHeight: 400)
            .padding(.horizontal, 8)
            
            if !displayTop {
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .coordinateSpace(name: "todo-card")
        .onAppear {
            syncDisplayTop()
        }
        .onChange(of: todoTitleEditID) { _ in
            syncDisplayTop()
        }
    }
    
    func syncDisplayTop() {
        if todoTitleEditID == nil {
            withAnimation {
                displayTop = true
            }
        } else {
            withAnimation {
                displayTop = false
            }
        }
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
