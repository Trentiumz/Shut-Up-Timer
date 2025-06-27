import SwiftUI;

struct TodoView : View {
    // whether or not we're expanded
    @Binding var expanded: Bool;
    
    // tracking current list items & what to add
    @EnvironmentObject var todoList: ToDoList;
    @State private var textInputModalShowed: Bool = false;
    
    @Binding private var selectedTodo: UUID;
    
    @State private var editingTodo: UUID = UUID();
    @FocusState private var editingFocus: Bool;
    
    var namespace: Namespace.ID
    var isSource: Bool
    var canSelect: Bool = true
    
    static var mainAnimation = Animation.interactiveSpring(response: 0.4, dampingFraction: 0.6, blendDuration: 0.25);
    
    init(expanded: Binding<Bool>, selectedTodo: Binding<UUID>, namespace: Namespace.ID, isSource: Bool, canSelect: Bool = true) {
        _expanded = expanded;
        _selectedTodo = selectedTodo;
        self.namespace = namespace;
        self.isSource = isSource;
        self.canSelect = canSelect;
    }
    
    // adds a task and saves it
    func addTask(_ newTaskText: String) {
        DispatchQueue.main.async {
            todoList.lst.append(ToDoEntry(todo: newTaskText))
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
                        editingFocus = false;
                    }
                }
            VStack {
                Spacer()
                    .frame(height: expanded ? 80 : 25)
                    .matchedGeometryEffect(id: "todo-top-spacer", in: namespace, isSource: isSource)
                GeometryReader { _ in
                    VStack {
                        VStack {
                            List {
                                // list of items
                                ForEach(todoList.lst.indices.filter {todoList.lst[$0].active}, id: \.self) { index in
                                    TodoEntryView(
                                        entry: $todoList.lst[index],
                                        selected: selectedTodo == todoList.lst[index].id,
                                        isEditing: editingTodo == todoList.lst[index].id,
                                        onSelect: {
                                            if self.canSelect {
                                                selectedTodo=todoList.lst[index].id
                                            }
                                        },
                                        onUnselect: {
                                            if selectedTodo == todoList.lst[index].id {
                                                selectedTodo = UUID();
                                            }
                                        },
                                        startEditing: {
                                            editingTodo = todoList.lst[index].id;
                                        },
                                        cancelEditing: {
                                            editingTodo = UUID();
                                        },
                                        isFocused: $editingFocus)
                                        .listRowInsets(EdgeInsets())
                                        .frame(maxWidth: .infinity)
                                        .padding(.leading, 0)
                                        .matchedGeometryEffect(id: "todo-item-\(index)", in: namespace, isSource: isSource)
                                }
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
    @Binding private var entry: ToDoEntry;
    var selected: Bool;
    var isEditing: Bool;
    var onSelect: () -> Void;
    var onUnselect: () -> Void;
    var startEditing: () -> Void;
    var cancelEditing: () -> Void;
    
    @FocusState.Binding private var isFocused: Bool
    
    init(entry: Binding<ToDoEntry>, selected: Bool, isEditing: Bool, onSelect: @escaping () -> Void, onUnselect: @escaping () -> Void, startEditing: @escaping () -> Void, cancelEditing: @escaping () -> Void, isFocused: FocusState<Bool>.Binding) {
        self._entry = entry;
        self.selected = selected;
        self.isEditing = isEditing;
        self.onSelect = onSelect;
        self.onUnselect = onUnselect;
        self.startEditing = startEditing;
        self.cancelEditing = cancelEditing;
        self._isFocused = isFocused;
    }
    
    var body : some View {
        HStack {
            if (selected) {
                Checkbox(checked: selected)
            }
            if isEditing {
                TextField("", text: $entry.todo)
                    .onSubmit {
                        cancelEditing()
                        withAnimation {
                            isFocused = false;
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
                Text(entry.todo)
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
                entry.active = false
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

struct TodoPreview : PreviewProvider {
    struct Wrapper : View {
        @State var selectedTodo: UUID = UUID()
        @State var expanded: Bool = true;
        @Namespace var sampleNamespace
        
        var body : some View {
            TodoView(expanded: $expanded, selectedTodo: $selectedTodo, namespace: sampleNamespace, isSource: true)
                .environmentObject(ToDoList(lst: [ToDoEntry(todo: "Hello"), ToDoEntry(todo: "No More"), ToDoEntry(todo: "No More"), ToDoEntry(todo: "No More"), ToDoEntry(todo: "No More"), ToDoEntry(todo: "No More"), ToDoEntry(todo: "No More"), ToDoEntry(todo: "No More"), ToDoEntry(todo: "No More"), ToDoEntry(todo: "No More")]))
        }
    }
    
    static var previews: some View {
        Wrapper()
    }
}
