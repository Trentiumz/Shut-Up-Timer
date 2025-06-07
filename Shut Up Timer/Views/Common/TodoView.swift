import SwiftUI;

struct TodoView : View {
    // whether or not we're expanded
    @Binding var expanded: Bool;
    
    // tracking current list items & what to add
    @EnvironmentObject var todoList: ToDoList;
    @State private var newTaskText: String;
    
    @Binding private var selectedTodo: UUID;
    
    init(expanded: Binding<Bool>, selectedTodo: Binding<UUID>) {
        _expanded = expanded;
        _selectedTodo = selectedTodo;
        newTaskText = "";
    }
    
    // adds a task and saves it
    func addTask() {
        DispatchQueue.main.async {
            todoList.lst.append(ToDoEntry(todo: newTaskText))
            newTaskText = ""
        }
    }
    
    // select a task
    func select(id: UUID) {
        selectedTodo = id;
    }
    
    var body : some View {
        ZStack(alignment: .top) {
            TodoPaper(width: expanded ? 350 : 150)
            VStack {
                Spacer()
                    .frame(height: expanded ? 80 : 25)
                GeometryReader { _ in
                    VStack {
                        List {
                            // list of items
                            ForEach(todoList.lst.indices.filter {todoList.lst[$0].active}, id: \.self) { index in
                                TodoEntryView(entry: $todoList.lst[index], selected: selectedTodo == todoList.lst[index].id, onSelect: { selectedTodo=todoList.lst[index].id})
                                    .listRowInsets(EdgeInsets())
                                    .frame(maxWidth: .infinity)
                                    .padding(.leading, 0)
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .frame(maxHeight: .infinity)
                        
                        // when expanded, allow adding tasks
                        if expanded {
                            HStack {
                                TextField("Add a new Task", text: $newTaskText, onCommit: addTask)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .padding()
                                Spacer()
                            }
                        }
                        
                        Spacer()
                    }.frame(maxHeight: .infinity)
                }
                .frame(width: expanded ? 240 : 120, height: expanded ? 370 : 160)
                .offset(x: expanded ? 10 : 0)
            }
        }
    }
}

struct TodoEntryView : View {
    @Binding private var entry: ToDoEntry;
    var selected: Bool;
    var onSelect: () -> Void;
    
    init(entry: Binding<ToDoEntry>, selected: Bool, onSelect: @escaping () -> Void) {
        self._entry = entry;
        self.selected = selected;
        self.onSelect = onSelect;
    }
    
    var body : some View {
        HStack {
            Text(entry.todo)
              .font(Font.custom("ArchitectsDaughter-Regular", size: 25))
              .strikethrough(entry.completed)
              .foregroundColor(ColorTokens.shade700)
              .frame(height: 25, alignment: .leading)
              .lineLimit(1)
              .truncationMode(.tail)
              .clipped()
            Spacer()
        }
        .onTapGesture(count: 2) {
            print("Removing entry \(entry.todo)")
            withAnimation {
                entry.completed = !entry.completed;
            }
        }
        .onTapGesture(count: 1) {
            print("Selecting entry \(entry.todo)")
            withAnimation {
                onSelect()
            }
        }
        .swipeActions {
            Button(role: .destructive) {
                entry.active = false
            } label: {
                Label("Delete", systemImage: "trash")
            }
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

#Preview {
//    TodoPaper(width: 200)
//        .frame(height: 300, alignment: .top)
//        .clipped()
    
    TodoView(expanded: .constant(true), selectedTodo: .constant(UUID()))
        .environmentObject(ToDoList(lst: [ToDoEntry(todo: "Hello"), ToDoEntry(todo: "No More"), ToDoEntry(todo: "No More"), ToDoEntry(todo: "No More"), ToDoEntry(todo: "No More"), ToDoEntry(todo: "No More"), ToDoEntry(todo: "No More"), ToDoEntry(todo: "No More"), ToDoEntry(todo: "No More"), ToDoEntry(todo: "No More")]))
}
