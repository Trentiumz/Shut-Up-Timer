import SwiftUI
import CoreData

struct TaskListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedTab: TaskTab = .myTasks
    let onAddGoal: (() -> Void)
    let onAddTask: (() -> Void)
    let onRedeem: (Goal) -> Void
    
    enum FocusItem: Hashable {
        case taskTitle(id: UUID)
        case goalTitle(id: UUID)
        case iqGoal(id: UUID)
    }
    @FocusState.Binding var fieldFocusItem: FocusItem?
    
    init(onAddGoal: @escaping () -> Void, onAddTask: @escaping () -> Void, onRedeem: @escaping (Goal) -> Void, fieldFocusItem: FocusState<FocusItem?>.Binding) {
        self.onAddGoal = onAddGoal
        self.onAddTask = onAddTask
        self.onRedeem = onRedeem
        self._fieldFocusItem = fieldFocusItem
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
                                TasksContentView(
                                    fieldFocusItem: _fieldFocusItem
                                )
                            } else {
                                DreamGoalsContentView(
                                    fieldFocusItem: _fieldFocusItem,
                                    onRedeem: onRedeem
                                )
                            }
                            
                            // Plus button at bottom
                            HStack {
                                Spacer()
                                
                                Button(action: {
                                    if selectedTab == .dreamGoals {
                                        onAddGoal()
                                    } else {
                                        onAddTask()
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
    
    // Fetch active todos using @FetchRequest with order-based sorting
    @FetchRequest(
        entity: Todo.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Todo.order, ascending: true),
                          NSSortDescriptor(keyPath: \Todo.created, ascending: false)],
        predicate: NSPredicate(format: "active == YES AND (goal == nil OR (goal.active == YES AND goal.redeemedAt == nil))")
    ) private var activeTodos: FetchedResults<Todo>
    
    // Fetch goals using @FetchRequest for automatic updates
    @FetchRequest(
        entity: Goal.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Goal.order, ascending: true),
                          NSSortDescriptor(keyPath: \Goal.created, ascending: false)],
        predicate: NSPredicate(format: "active == YES AND redeemedAt == nil")
    ) private var goals: FetchedResults<Goal>
    
    @FocusState.Binding var fieldFocusItem: TaskListView.FocusItem?
    
    var body: some View {
        return List {
            ForEach(activeTodos, id: \.id) { task in
                TaskRowView(
                    task: task,
                    availableGoals: goals,
                    fieldFocusItem: _fieldFocusItem
                )
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }
            .onMove { inds, newOffset in
                do {
                    var tempTasks = Array(activeTodos)
                    tempTasks.move(fromOffsets: inds, toOffset: newOffset)
                    tempTasks.enumerated().forEach { ind, task in
                        task.order = Int16(ind)
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

struct TaskSelectable: EnvironmentKey {
    static let defaultValue: TaskSelectable? = nil
    
    let title: String
    let onSelect: (Todo) -> Void
}
extension EnvironmentValues {
    var taskSelectable: TaskSelectable? {
        get {self[TaskSelectable.self]}
        set {self[TaskSelectable.self] = newValue}
    }
}

struct TaskRowView: View {
    @ObservedObject var task: Todo
    var availableGoals: FetchedResults<Goal>
    @Environment(\.managedObjectContext) private var viewContext
    
    @State var rectState = ExpandingGestureState(maxOffset: 60)
    @State private var showingGoalPicker = false
    
    @FocusState.Binding var fieldFocusItem: TaskListView.FocusItem?
    
    @Environment(\.taskSelectable) var taskSelectable
    
    var goalColor: Color {
        return task.goal?.realColor ?? Color.black
    }
    
    var body: some View {
        HStack {
            // Expanding rectangle with text
            RoundedRectangle(cornerRadius: 4)
                .fill(goalColor)
                .frame(width: 4 + rectState.dragOffset, height: 20)
                .overlay(
                    HStack {
                        Text(task.goal?.goal ?? "No Goal")
                            .font(FontTokens.architectsDaughter(size: 14))
                            .foregroundColor(task.goal == nil ? Color.red : goodOverlayColor(for: goalColor))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .frame(width: rectState.maxOffset - 12 + 4, alignment: .center) // Fixed size equal to maxOffset
                        Spacer()
                    }
                    .padding(.leading, 8),
                    alignment: .leading
                )
                .clipped() // Clip to fit within the rectangle
                .onTapGesture {
                    showingGoalPicker = true;
                }
            
            TextField("", text: Binding<String>(
                get: { task.todo ?? "" },
                set: { val in
                    do {
                        task.todo = val
                        try viewContext.save()
                    } catch {
                        print("Failed to save new value..")
                    }
                }
            ))
            .focused(_fieldFocusItem, equals: .taskTitle(id: task.id ?? UUID()))
            .font(FontTokens.architectsDaughter(size: 12))
            .foregroundColor(.black)
            .strikethrough(task.completed)
            .lineLimit(1)
            
            Rectangle()
                .fill(.clear)
                .contentShape(Rectangle())
                .layoutPriority(-1)
            
            if let taskSelectable = taskSelectable {
                TaskSelectText(text: taskSelectable.title)
                    .onTapGesture {
                        taskSelectable.onSelect(task)
                    }
            }
        }
        .simultaneousGesture(
            ExpandingGestureState.getDragGesture(state: $rectState)
        )
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            if rectState.dragOffset == 0 {
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
                
                if !task.completed {
                    Button {
                        do {
                            let byOrder = Todo.fetchRequest()
                            byOrder.sortDescriptors = [NSSortDescriptor(key: "order", ascending: false)]
                            byOrder.fetchLimit = 1
                            byOrder.propertiesToFetch = ["order"]
                            byOrder.resultType = .managedObjectResultType
                            
                            var maxOrder: Int16 = 0
                            if let result = try viewContext.fetch(byOrder).first {
                                maxOrder = result.value(forKey: "order") as? Int16 ?? 0
                            }
                            
                            task.completed = true
                            task.order = maxOrder + 1
                            try viewContext.save()
                        } catch {
                            print("Error marking todo as completed: \(error)")
                        }
                    } label: {
                        Label("Mark as Complete", systemImage: "checkmark.square")
                    }
                    .tint(.mint)
                } else {
                    Button() {
                        do {
                            task.completed = false
                            try viewContext.save()
                        } catch {
                            print("Error marking todo as incomplete: \(error)")
                        }
                    } label: {
                        Label("Mark as Incomplete", systemImage: "x.square")
                    }
                    .tint(.orange)
                }
            }
        }
        .confirmationDialog("Select Goal", isPresented: $showingGoalPicker, titleVisibility: .visible) {
            Button("No Goal") {
                task.goal = nil
                do {
                    try viewContext.save()
                } catch {
                    print("Failed to save goal change: \(error)")
                }
            }
            
            ForEach(availableGoals, id: \.id) { goal in
                Button(goal.goal ?? "Unknown Goal") {
                    task.goal = goal
                    do {
                        try viewContext.save()
                    } catch {
                        print("Failed to save goal change: \(error)")
                    }
                }
            }
            
            Button("Cancel", role: .cancel) { }
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
        predicate: NSPredicate(format: "redeemedAt == nil")
    ) private var goals: FetchedResults<Goal>
    
    @FocusState.Binding var fieldFocusItem: TaskListView.FocusItem?
    let onRedeem: (Goal) -> Void
    
    var body: some View {
        return List {
            ForEach(goals, id: \.id) { goal in
                DreamGoalRowView(goal: goal, fieldFocusItem: _fieldFocusItem, onRedeem: onRedeem)
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
    @ObservedObject var goal: Goal
    @Environment(\.managedObjectContext) private var viewContext
    
    @State var rectState = ExpandingGestureState(maxOffset: 60)
    @State private var iqGoalText: String = ""
    
    @FocusState.Binding var fieldFocusItem: TaskListView.FocusItem?
    @State var isEditingGoal: Bool = false
    let onRedeem: (Goal) -> Void
    
    func getGoalColor(curColor: String?) -> Color {
        if let gColor = curColor {
            return hexStringToColor(gColor)
        } else {
            return ColorTokens.red300
        }
    }
    
    func submitIQGoalChange() {
        if let iqGoalValue = Double(iqGoalText), iqGoalValue > 0 {
            goal.addProgress(iqCurrent: goal.lastGoalProgress?.iqCurrent ?? 0, iqGoal: iqGoalValue)
            do {
                try viewContext.save()
            } catch {
                print("Failed to save IQ goal: \(error)")
            }
        }
        fieldFocusItem = nil
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(getGoalColor(curColor: goal.color))
                    .frame(width: 4 + rectState.dragOffset, height: 20)
                    .onTapGesture {
                        do {
                            goal.color = colorToHexString(randomGoalColor())
                            try viewContext.save()
                        } catch {
                            print("Error saving new color: \(error)")
                        }
                    }
                
                TextField("", text: Binding<String>(
                    get: { goal.goal ?? "Unknown Goal" },
                    set: { val in
                        do {
                            goal.goal = val
                            try viewContext.save()
                        } catch {
                            print("Failed to save new value..")
                        }
                    }
                ))
                .focused(_fieldFocusItem, equals: .goalTitle(id: goal.id ?? UUID()))
                .font(FontTokens.architectsDaughter(size: 12))
                .foregroundColor(.black)
                .lineLimit(1)
                
                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())
                    .layoutPriority(-1)
                
                // IQ Goal editing section
                if isEditingGoal {
                    TextField("Enter new IQ Goal", text: $iqGoalText)
                        .focused(_fieldFocusItem, equals: .iqGoal(id: goal.id ?? UUID()))
                        .font(FontTokens.architectsDaughter(size: 10))
                        .multilineTextAlignment(.trailing)
                        .foregroundColor(ColorTokens.shade600)
                        .keyboardType(.numberPad)
                        .toolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                Spacer()
                                Button("Done") {
                                    submitIQGoalChange()
                                    // Dismiss keyboard
                                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                }
                            }
                        }
                        .onSubmit {
                            submitIQGoalChange()
                        }
                        .onAppear {
                            iqGoalText = String(Int(goal.lastGoalProgress?.iqGoal ?? 0))
                            fieldFocusItem = .iqGoal(id: goal.id ?? UUID())
                        }
                        .onChange(of: fieldFocusItem) { val in
                            if val != .iqGoal(id: goal.id ?? UUID()) {
                                isEditingGoal = false
                                iqGoalText = ""
                            }
                        }
                } else {
                    Text("[\(Int(goal.lastGoalProgress?.iqCurrent ?? 0)) / \(Int(goal.lastGoalProgress?.iqGoal ?? 0)) IQ Points]")
                        .font(FontTokens.architectsDaughter(size: 10))
                        .foregroundColor(ColorTokens.shade600)
                        .onTapGesture {
                            isEditingGoal = true
                        }
                }
                
                // Show "Redeem" button for incomplete tasks only when not editing
                TaskSelectText(text: "Redeem")
                    .onTapGesture {
                        onRedeem(goal)
                    }
            }
            .simultaneousGesture(
                ExpandingGestureState.getDragGesture(state: $rectState)
            )
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                if rectState.dragOffset == 0 {
                    Button(role: .destructive) {
                        do {
                            viewContext.delete(goal)
                            try viewContext.save()
                        } catch {
                            print("Failed to remove goal: \(error)")
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
    }
}

struct ExpandingGestureState {
    var dragOffset: CGFloat = 0;
    var lastDragOffset: CGFloat = 0;
    let maxOffset: CGFloat;
    
    static func getDragGesture(state: Binding<ExpandingGestureState>) -> some Gesture {
        return DragGesture()
            .onChanged { value in
                let translation = value.translation.width
                state.wrappedValue.dragOffset = max(min(state.wrappedValue.lastDragOffset + translation, state.wrappedValue.maxOffset), 0)
            }
            .onEnded { _ in
                withAnimation {
                    if state.wrappedValue.dragOffset > state.wrappedValue.maxOffset * 3 / 4 {
                        state.wrappedValue.dragOffset = state.wrappedValue.maxOffset;
                    } else {
                        state.wrappedValue.dragOffset = 0
                    }
                    state.wrappedValue.lastDragOffset = state.wrappedValue.dragOffset
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

fileprivate struct TaskSelectText: View {
    let text: String
    var body: some View {
        Text(text)
            .font(FontTokens.architectsDaughter(size: 10))
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(ColorTokens.red300)
            .cornerRadius(4)
            .frame(width: 60, height: 20)
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
        
        let goal2 = Goal(context: viewContext)
        goal2.created = Date()
        goal2.goal = "Ace Math #2!"
        goal2.id = UUID()
        
        let todo1 = Todo(context: viewContext)
        todo1.id = UUID()
        todo1.todo = "Todo 1"
        todo1.created = Date()
        todo1.goal = goal
        
        let todo2 = Todo(context: viewContext)
        todo2.id = UUID()
        todo2.todo = "Todo 1"
        todo2.created = Date()
        
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
        @FocusState var fieldFocusItem: TaskListView.FocusItem?
        
        var body : some View {
            TaskListView(onAddGoal: {}, onAddTask: {}, onRedeem: { _ in }, fieldFocusItem: $fieldFocusItem)
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
