import SwiftUI;
import SwiftUIReorderableForEach;

struct TodoView : View {
    // whether or not we're expanded
    @Binding var expanded: Bool;
    
    // Core Data access
    @Environment(\.managedObjectContext) private var viewContext
    
    // Fetch active todos using @FetchRequest for automatic updates
    @FetchRequest(
        entity: Todo.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Todo.created, ascending: false)],
        predicate: NSPredicate(format: "active == YES")
    ) private var activeTodos: FetchedResults<Todo>
    
    @State private var textInputModalShowed: Bool = false;
    @Binding private var selectedTodo: UUID;
    
    @FocusState private var isFocused: Bool;
    
    var namespace: Namespace.ID
    var isSource: Bool
    var canSelect: Bool = true
    
    var isActive: Bool;
    
    static var mainAnimation = Animation.interactiveSpring(response: 0.4, dampingFraction: 0.6, blendDuration: 0.25);
    
    init(expanded: Binding<Bool>, selectedTodo: Binding<UUID>, namespace: Namespace.ID, isSource: Bool, canSelect: Bool = true, isActive: Bool) {
        _expanded = expanded;
        _selectedTodo = selectedTodo;
        self.namespace = namespace;
        self.isSource = isSource;
        self.canSelect = canSelect;
        self.isActive = isActive;
    }
    
    // adds a task and saves it to Core Data
    func addTask(_ newTaskText: String) {
        DispatchQueue.main.async {
            let newTodo = Todo(context: viewContext)
            newTodo.id = UUID()
            newTodo.todo = newTaskText
            newTodo.active = true
            newTodo.completed = false
            newTodo.created = Date()
            
            do {
                try viewContext.save()
            } catch {
                print("Failed to save new todo: \(error)")
            }
        }
    }
    
    // select a task
    func select(id: UUID) {
        selectedTodo = id;
    }
    
    var body : some View {
        ZStack(alignment: .top) {
            TodoPaper(width: expanded ? 350 : 150)
                .matchedGeometryEffect(id: "todo-paper", in: namespace, isSource: isSource)
                .onTapGesture {
                    withAnimation {
                        expanded = !expanded;
                        isFocused = false;
                    }
                }
                .allowsHitTesting(isActive)
            VStack {
                Spacer()
                    .frame(height: expanded ? 80 : 25)
                    .matchedGeometryEffect(id: "todo-top-spacer", in: namespace, isSource: isSource)
                GeometryReader { _ in
                    VStack {
                        VStack {
                            List {
                                // list of items
                                TodoItemList(selectedTodo: _selectedTodo, isFocused: $isFocused, isSource: isSource, canSelect: canSelect, namespace: namespace)
                            }
                            .listStyle(.plain)
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                            .frame(maxHeight: .infinity)
                            .matchedGeometryEffect(id: "todo-list", in: namespace, isSource: isSource)
                        }
                        
                        Spacer()
                            .matchedGeometryEffect(id: "todo-mid-spacer", in: namespace, isSource: isSource)
                        
                        // when expanded, allow adding tasks
                        HStack {
                            Spacer()
                            Button(action: {
                                textInputModalShowed = true;
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(Color.blue)
                                        .frame(width: 50, height: 50)
                                        .matchedGeometryEffect(id: "todo-add-circle", in: namespace, isSource: isSource)
                                    Image(systemName: "plus")
                                        .foregroundColor(.white)
                                        .font(.system(size: 24, weight: .bold))
                                        .matchedGeometryEffect(id: "todo-add-icon", in: namespace, isSource: isSource)
                                }
                                .transition(.opacity)
                            }.sheet(isPresented: $textInputModalShowed) {
                                TextInputModal(onSave: { task in
                                    addTask(task)
                                }, onCancel: {textInputModalShowed = false}
                                )
                                .presentationDetents([.height(200)])
                            }
                            .frame(width: expanded ? 50 : 0, height: expanded ? 50 : 0)
                        }
                        .opacity(expanded ? 1 : 0)
                        .transition(.opacity)
                    }
                    .frame(maxHeight: .infinity)
                }
            }
            .frame(width: expanded ? 240 : 120, height: expanded ? 460 : 160)
        }
        .frame(width: expanded ? 350 : 150, height: expanded ? 500 : 180, alignment: .top)
    }
}

struct TodoItemList : View {
    @Environment(\.managedObjectContext) private var viewContext
    
    // Fetch active todos using @FetchRequest for automatic updates
    @FetchRequest(
        entity: Todo.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Todo.created, ascending: false)],
        predicate: NSPredicate(format: "active == YES")
    ) private var activeTodos: FetchedResults<Todo>
    
    @Binding var selectedTodo: UUID;
    @State private var editingTodo: UUID = UUID();
    @FocusState.Binding var isFocused: Bool;
    
    var isSource: Bool;
    var canSelect: Bool = true;
    var namespace: Namespace.ID;
    
    @State var allowReordering = true
    
    // Remove task by setting active to false
    func removeTask(_ todo: Todo) {
        todo.active = false
        do {
            try viewContext.save()
        } catch {
            print("Failed to remove todo: \(error)")
        }
    }
    
    var body : some View {
        ForEach(Array(activeTodos), id: \.objectID) { todo in
            TodoEntryView(
                entry: todo,
                selected: selectedTodo == todo.id,
                isEditing: editingTodo == todo.id,
                onSelect: {
                    if self.canSelect {
                        selectedTodo = todo.id ?? UUID()
                    }
                },
                onUnselect: {
                    if selectedTodo == todo.id {
                        selectedTodo = UUID();
                    }
                },
                startEditing: {
                    editingTodo = todo.id ?? UUID();
                },
                cancelEditing: {
                    editingTodo = UUID();
                },
                removeItem: {
                    removeTask(todo);
                },
                isFocused: _isFocused)
                .listRowInsets(EdgeInsets())
                .frame(maxWidth: .infinity)
                .padding(.leading, 0)
                .matchedGeometryEffect(id: "todo-item-\(todo.id?.uuidString ?? "")", in: namespace, isSource: isSource)
        }
        .onMove(perform: move)
    }
    
    func move(from source: IndexSet, to destination: Int) {
        // Note: Core Data doesn't have built-in ordering like arrays
        // For now, we'll just log this - you might want to add an order field to Todo
        print("Move operation not implemented for Core Data todos")
    }
}

struct TextInputModal: View {
    @State var inputText: String = ""
    var onSave: (String) -> Void
    var onCancel: () -> Void = {}

    var body: some View {
        VStack {
            TextField("Enter your task...", text: $inputText, onCommit: {
                onSave(inputText)
            })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Spacer()
        }
        .padding()
    }
}

struct Checkbox: View {
    var checked: Bool;

    var body: some View {
        Image(systemName: checked ? "checkmark.square.fill" : "square")
            .foregroundColor(checked ? .blue : .gray)
            .font(.title2)
    }
}

struct TodoEntryView : View {
    @ObservedObject var entry: Todo;
    @Environment(\.managedObjectContext) private var viewContext
    
    var selected: Bool;
    var isEditing: Bool;
    var onSelect: () -> Void;
    var onUnselect: () -> Void;
    var removeItem: () -> Void;
    var startEditing: () -> Void;
    var cancelEditing: () -> Void;
    
    @FocusState.Binding private var isFocused: Bool
    
    init(entry: Todo, selected: Bool, isEditing: Bool, onSelect: @escaping () -> Void, onUnselect: @escaping () -> Void, startEditing: @escaping () -> Void, cancelEditing: @escaping () -> Void, removeItem: @escaping () -> Void, isFocused: FocusState<Bool>.Binding) {
        self.entry = entry;
        self.selected = selected;
        self.isEditing = isEditing;
        self.onSelect = onSelect;
        self.onUnselect = onUnselect;
        self.startEditing = startEditing;
        self.removeItem = removeItem;
        self.cancelEditing = cancelEditing;
        self._isFocused = isFocused;
    }
    
    var body : some View {
        HStack {
            if (selected) {
                Checkbox(checked: selected)
            }
            if isEditing {
                TextField("", text: Binding(
                    get: { entry.todo ?? "" },
                    set: { entry.todo = $0 }
                ))
                    .onSubmit {
                        do {
                            try viewContext.save()
                            cancelEditing()
                            withAnimation {
                                isFocused = false;
                            }
                        } catch {
                            print("Failed to save todo: \(error)")
                        }
                    }
                    .focused(_isFocused)
                    .font(Font.custom("ArchitectsDaughter-Regular", size: 25))
                    .foregroundColor(ColorTokens.shade700)
                    .strikethrough(entry.completed)
                    .frame(height: 25, alignment: .leading)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .clipped()
            } else {
                Text(entry.todo ?? "")
                    .font(Font.custom("ArchitectsDaughter-Regular", size: 25))
                    .strikethrough(entry.completed)
                    .foregroundColor(ColorTokens.shade700)
                    .frame(height: 25, alignment: .leading)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .clipped()
            }
            Spacer()
        }
        .onTapGesture(count: 2) {
            withAnimation {
                onUnselect();
                entry.completed = !entry.completed;
                do {
                    try viewContext.save()
                } catch {
                    print("Failed to toggle completion: \(error)")
                }
                isFocused = false;
            }
        }
        .onTapGesture(count: 1) {
            if !entry.completed {
                if selected {
                    withAnimation {
                        onUnselect()
                        isFocused = false;
                    }
                } else {
                    withAnimation {
                        onSelect()
                        isFocused = false;
                    }
                }
            }
        }
        .swipeActions {
            Button(role: .destructive) {
                removeItem()
                isFocused = false;
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

struct TodoPaper : View {
    private let oWidth: CGFloat = 310;
    private let oHeight: CGFloat = 410;
    private let scaleFactor: CGFloat;
    private let width: CGFloat;
    
    init(width: CGFloat){
        scaleFactor = width / oWidth;
        self.width = width;
    }
    
    var body : some View {
        VStack(alignment: .leading) {
            ImageAssets.todoPaper39
                .aspectRatio(contentMode: .fill)
                .frame(width: oWidth, height: oHeight)
                .offset(x: 45, y: -15)
        }
        .scaleEffect(scaleFactor)
        .frame(width: width, height: width / oWidth * oHeight)
    }
}

fileprivate struct Wrapper : View {
    @Namespace var namespace
    @State var expanded = true
    @State var selectedTodo = UUID()
    
    var body : some View {
        return TodoView(expanded: $expanded, selectedTodo: $selectedTodo, namespace: namespace, isSource: true, isActive: true)
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}
struct TodoViewPreview: PreviewProvider {
    static var previews: some View {
        Wrapper()
    }
}
