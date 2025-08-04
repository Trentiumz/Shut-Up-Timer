import SwiftUI
import CoreData

enum TopTaskScreen {
    case start
    case addGoal
    case addTask
    case redeem(goal: Goal)
    case other
}

struct TaskView<DefaultViewType: View, OtherViewType: View>: View {
    @Binding private var taskScreen: TopTaskScreen
    @Environment(\.managedObjectContext) private var viewContext
    
    @FocusState var fieldFocusItem: TaskListView.FocusItem?
    @State private var displayTop: Bool = true
    
    @ViewBuilder var startView: () -> DefaultViewType
    @ViewBuilder var otherView: () -> OtherViewType
    
    init(taskScreen: Binding<TopTaskScreen>, @ViewBuilder startView: @escaping () -> DefaultViewType, @ViewBuilder otherView: @escaping () -> OtherViewType) {
        self._taskScreen = taskScreen;
        self.startView = startView
        self.otherView = otherView
    }
    
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
                                taskScreen = .start
                            }
                        }
                    } onCancel: {
                        withAnimation {
                            taskScreen = .start
                        }
                    }
                    .padding()
                    .transition(rightwardAnimation)
                case .start:
                    startView()
                        .transition(rightwardAnimation)
                case .addTask:
                    TaskAddView(
                        onTaskAdd: { tasks in
                            withAnimation {
                                let success = addTasks(tasks)
                                if success {
                                    taskScreen = .start
                                }
                            }
                        },
                        onCancel: {
                            withAnimation {
                                taskScreen = .start
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
                                    taskScreen = .start
                                }
                            } catch {
                                print("Error redeeming goal: \(error)")
                            }
                        },
                        onCancel: {
                            withAnimation {
                                taskScreen = .start
                            }
                        }
                    )
                    .padding()
                    .transition(rightwardAnimation)
                case .other:
                    otherView()
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
                fieldFocusItem: $fieldFocusItem
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
        .onChange(of: fieldFocusItem) { _ in
            syncDisplayTop()
        }
    }
    
    func syncDisplayTop() {
        if fieldFocusItem == nil {
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
            goal.addProgress(iqCurrent: 0.0, iqGoal: temporaryGoal.iqGoal)
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

struct TaskViewWrapper : PreviewProvider {
    struct Wrapper: View {
        @State var taskScreen: TopTaskScreen = .start
        var body: some View {
            TaskView<TodoBeckonView, EmptyView>(taskScreen: $taskScreen, startView: {
                TodoBeckonView()
            }, otherView: { EmptyView() })
                .environmentObject(AppRouter())
                .environmentObject(SettingsLoader.loadSettings())
        }
    }
    
    static var previews: some View {
        Wrapper()
    }
}
