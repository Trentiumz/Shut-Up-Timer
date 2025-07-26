import SwiftUI
import CoreData

struct TaskListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedTab: TaskTab = .myTasks
    let onAddGoal: (() -> Void)
    
    init(onAddGoal: @escaping () -> Void) {
        self.onAddGoal = onAddGoal
    }
    
    enum TaskTab: CaseIterable {
        case myTasks
        case dreamGoals
        
        var title: String {
            switch self {
            case .myTasks: return "My Tasks"
            case .dreamGoals: return "Dream Goals"
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Tab buttons at the top
            HStack(spacing: 0) {
                ForEach(TaskTab.allCases, id: \.self) { tab in
                    Button(action: {
                        selectedTab = tab
                    }) {
                        Text(tab.title)
                            .font(FontTokens.architectsDaughter(size: 16))
                            .foregroundColor(selectedTab == tab ? ColorTokens.shade700 : ColorTokens.shade100)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 4)
                            .frame(minWidth: 90, minHeight: 30)
                            .background(
                                Rectangle()
                                    .fill(selectedTab == tab ? ColorTokens.shade200 : ColorTokens.red300)
                                    .frame(minHeight: 60)
                                    .overlay(
                                        Rectangle()
                                            .inset(by: 0)
                                            .stroke(.black, lineWidth: 2)
                                    ),
                                alignment: .top
                            )
                    }
                }
                
                Spacer()
            }
            .padding(.top, 10)
            
            // Main content area
            VStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(ColorTokens.shade200)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .inset(by: 0)
                            .stroke(.black, lineWidth: 2)
                    )
                    .overlay(
                        // Content inside the main area
                        VStack(alignment: .leading, spacing: 8) {
                            if selectedTab == .myTasks {
                                TasksContentView()
                            } else {
                                DreamGoalsContentView()
                            }
                            
                            // Plus button at bottom
                            HStack {
                                Spacer()
                                
                                Button(action: {
                                    if selectedTab == .dreamGoals {
                                        onAddGoal()
                                    } else {
                                        // TODO: Add task functionality later
                                    }
                                }) {
                                    Text("+")
                                        .font(FontTokens.architectsDaughter(size: 30))
                                        .foregroundColor(.white)
                                        .frame(width: 40, height: 40)
                                        .background(ColorTokens.red300)
                                        .cornerRadius(10)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .inset(by: 1)
                                                .stroke(.black, lineWidth: 1)
                                        )
                                }
                            }
                        }
                        .padding(16)
                    )
                
                Spacer()
            }
        }
        .padding(.horizontal, 20)
    }
}

struct TasksContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var editingTask: UUID = UUID()
    @FocusState private var isFocused: Bool
    
    // Fetch active todos using @FetchRequest for automatic updates
    @FetchRequest(
        entity: Todo.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Todo.created, ascending: false)],
        predicate: NSPredicate(format: "active == YES")
    ) private var activeTodos: FetchedResults<Todo>
    
    // Fetch goals using @FetchRequest for automatic updates
    @FetchRequest(
        entity: Goal.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Goal.order, ascending: true),
                          NSSortDescriptor(keyPath: \Goal.created, ascending: false)],
        predicate: NSPredicate(format: "redeemed == false")
    ) private var goals: FetchedResults<Goal>
    
    var body: some View {
        return ScrollView {
            LazyVStack(alignment: .leading, spacing: 12) {
                // Group tasks by goals using Core Data
                ForEach(Array(goals), id: \.id) { goal in
                    VStack(alignment: .leading, spacing: 8) {
                        // Goal header
                        HStack {
                            Rectangle()
                                .fill(ColorTokens.red300)
                                .frame(width: 4, height: 20)
                            
                            Text(goal.goal ?? "Unknown Goal")
                                .font(FontTokens.architectsDaughter(size: 14))
                                .foregroundColor(.black)
                                .fontWeight(.semibold)
                            
                            Spacer()
                        }
                        
                        // Tasks for this goal using Core Data relationship
                        ForEach(Array(goal.tasksArray), id: \.id) { task in
                            TaskRowView(
                                task: task,
                                isEditing: editingTask == task.id,
                                startEditing: { editingTask = task.id ?? UUID() },
                                cancelEditing: { editingTask = UUID() },
                                isFocused: $isFocused
                            )
                        }
                    }
                }
                
                // Tasks without goals (existing tasks)
                let tasksWithoutGoals = activeTodos.filter { $0.goal == nil }
                if !tasksWithoutGoals.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Rectangle()
                                .fill(ColorTokens.red300)
                                .frame(width: 4, height: 20)
                            
                            Text("General Tasks")
                                .font(FontTokens.architectsDaughter(size: 14))
                                .foregroundColor(.black)
                                .fontWeight(.semibold)
                            
                            Spacer()
                        }
                        
                        ForEach(tasksWithoutGoals, id: \.id) { task in
                            TaskRowView(
                                task: task,
                                isEditing: editingTask == task.id,
                                startEditing: { editingTask = task.id ?? UUID() },
                                cancelEditing: { editingTask = UUID() },
                                isFocused: $isFocused
                            )
                        }
                    }
                }
            }
            .padding(.vertical, 8)
        }
    }
}

struct TaskRowView: View {
    @ObservedObject var task: Todo
    @Environment(\.managedObjectContext) private var viewContext
    
    var isEditing: Bool
    var startEditing: () -> Void
    var cancelEditing: () -> Void
    
    @FocusState.Binding var isFocused: Bool
    
    var body: some View {
        HStack {
            if isEditing {
                TextField("", text: Binding(
                    get: { task.todo ?? "" },
                    set: { task.todo = $0 }
                ))
                    .onSubmit {
                        do {
                            try viewContext.save()
                            cancelEditing()
                            withAnimation {
                                isFocused = false
                            }
                        } catch {
                            print("Failed to save todo: \(error)")
                        }
                    }
                    .focused($isFocused)
                    .font(FontTokens.architectsDaughter(size: 12))
                    .foregroundColor(.black)
                    .strikethrough(task.completed)
            } else {
                Text(task.todo ?? "")
                    .font(FontTokens.architectsDaughter(size: 12))
                    .foregroundColor(.black)
                    .strikethrough(task.completed)
            }
            
            Spacer()
        }
        .swipeActions {
            Button(role: .destructive) {
                task.active = false
                do {
                    try viewContext.save()
                } catch {
                    print("Failed to remove task: \(error)")
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
            
            Button {
                startEditing()
                isFocused = true
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            .tint(.blue)
        }
    }
}

struct DreamGoalsContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    // Fetch goals using @FetchRequest for automatic updates
    @FetchRequest(
        entity: Goal.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Goal.order, ascending: true),
                          NSSortDescriptor(keyPath: \Goal.created, ascending: false)],
        predicate: NSPredicate(format: "redeemed == false")
    ) private var goals: FetchedResults<Goal>
    
    var body: some View {
        return List {
            ForEach(goals, id: \.id) { goal in
                DreamGoalRowView(goal: goal)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
            }
            .onMove { inds, newOffset in
                do {
                    var tempGoals = Array(goals)
                    tempGoals.move(fromOffsets: inds, toOffset: newOffset)
                    tempGoals.enumerated().forEach { ind, goal in
                        goal.order = Int16(ind);
                    }
                    try viewContext.save()
                } catch {
                    print("Error moving elements: \(error)")
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .padding(.vertical, 8)
    }
}

struct DreamGoalRowView: View {
    let goal: Goal
    @Environment(\.managedObjectContext) private var viewContext
    
    func getGoalColor() -> Color {
        if let gColor = goal.color {
            return hexStringToColor(gColor)
        } else {
            return ColorTokens.red300
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Rectangle()
                    .fill(getGoalColor())
                    .frame(width: 4, height: 20)
                
                Text(goal.goal ?? "Unknown Goal")
                    .font(FontTokens.architectsDaughter(size: 12))
                    .foregroundColor(.black)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("[\(Int(goal.iqGoal)) IQ Points]")
                    .font(FontTokens.architectsDaughter(size: 10))
                    .foregroundColor(ColorTokens.shade600)
                
                // Show "Redeem" button for incomplete tasks only when not editing
                Button(action: {
                    goal.redeemed = true
                    do {
                        try viewContext.save()
                    } catch {
                        print("Failed to redeem goal: \(error)")
                    }
                }) {
                    Text("Redeem")
                        .font(FontTokens.architectsDaughter(size: 10))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(ColorTokens.red300)
                        .cornerRadius(4)
                        .frame(width: 60, height: 20)
                }
            }
            
            // Show progress if there are tasks
            if !goal.tasksArray.isEmpty {
                Text("Progress: \(String(format: "%.1f", goal.iqCurrent))/\(String(format: "%.1f", goal.iqGoal)) IQ")
                    .font(FontTokens.architectsDaughter(size: 10))
                    .foregroundColor(ColorTokens.shade500)
                    .padding(.leading, 8)
            }
        }
    }
}

// Extension to get tasks array from Goal
extension Goal {
    var tasksArray: [Todo] {
        let set = tasks as? Set<Todo> ?? []
        return set.sorted { 
            ($0.created ?? Date.distantPast) > ($1.created ?? Date.distantPast)
        }
    }
}

func addSampleDataToDB(viewContext: NSManagedObjectContext) {
    do {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Goal.fetchRequest()
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        let _ = try viewContext.execute(batchDeleteRequest) as? NSBatchDeleteResult
        try viewContext.save()
        viewContext.refreshAllObjects()
        
        let fetchRequest2: NSFetchRequest<NSFetchRequestResult> = Todo.fetchRequest()
        let batchDeleteRequest2 = NSBatchDeleteRequest(fetchRequest: fetchRequest2)
        let _ = try viewContext.execute(batchDeleteRequest2) as? NSBatchDeleteResult
        try viewContext.save()
        viewContext.refreshAllObjects()
        
        let goal = Goal(context: viewContext)
        goal.created = Date()
        goal.goal = "Ace Math!"
        goal.id = UUID()
        goal.iqGoal = 10.0
        goal.redeemed = false
        
        let goal2 = Goal(context: viewContext)
        goal2.created = Date()
        goal2.goal = "Ace Math #2!"
        goal2.id = UUID()
        goal2.iqGoal = 10.0
        goal2.redeemed = false
        
        let todo1 = Todo(context: viewContext)
        todo1.id = UUID()
        todo1.todo = "Todo 1"
        todo1.created = Date()
        todo1.goal = goal
        
        let todo2 = Todo(context: viewContext)
        todo2.id = UUID()
        todo2.todo = "Todo 1"
        todo2.created = Date()
        todo2.goal = nil
        
        try viewContext.save()
        viewContext.processPendingChanges()
        viewContext.refreshAllObjects()
    } catch {
        print("Something went wrong in TaskListPreview: \(error)")
    }
}

struct TaskListViewPreview : PreviewProvider {
    struct Wrapper : View {
        @Environment(\.managedObjectContext) private var viewContext
        
        var body : some View {
            TaskListView(onAddGoal: {})
                .onAppear {
                    addSampleDataToDB(viewContext: viewContext)
                }
        }
    }
    
    static var previews: some View {
        Wrapper()
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}
