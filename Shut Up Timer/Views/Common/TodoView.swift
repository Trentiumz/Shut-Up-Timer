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
        todoList.lst.append(ToDoEntry(todo: newTaskText))
        DispatchQueue.main.async {
            newTaskText = ""
        }
    }
    
    // select a task
    func select(id: UUID) {
        selectedTodo = id;
    }
    
    var body : some View {
        Button(action: {
            // expand and disexpand todo list
            withAnimation {
                expanded.toggle()
            }
        }) {
            ScrollView {
                VStack {
                    // list of items
                    ForEach(todoList.lst.filter { $0.active }) { item in
                        HStack {
                            Image(systemName: "trash")
                                .onTapGesture {
                                    withAnimation {
                                        if let index = todoList.lst.firstIndex(where: { $0.id == item.id }) {
                                            todoList.lst[index].active = false
                                        }
                                    }
                                }
                            // task
                            Text(item.todo)
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .clipped()
                                .onTapGesture {
                                    withAnimation {
                                        select(id: item.id)
                                    }
                                }
                            
                            Spacer()
                            
                            if selectedTodo == item.id {
                                Image(systemName: "star")
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .font(.title2)
                        .foregroundStyle(.black)
                    }.padding()
                    
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
                }
            }
            .frame(maxWidth: expanded ? .infinity : 150, maxHeight: expanded ? .infinity : 200)
            .background(.gray)
            .padding()
            .clipped()
        }
    }
}

#Preview {
    TodoView(expanded: .constant(true), selectedTodo: .constant(UUID()))
}
