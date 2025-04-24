import SwiftUI;

struct TodoView : View {
    // whether or not we're expanded
    @Binding var expanded: Bool;
    
    // tracking current list items & what to add
    @State private var listItems: [ToDoEntry];
    @State private var newTaskText: String;
    
    init(expanded: Binding<Bool>) {
        _expanded = expanded;
        newTaskText = "";
        listItems = ToDoList.getToDo()
    }
    
    // adds a task and saves it
    func addTask() {
        listItems = ToDoList.getToDo()
        listItems.append(ToDoEntry(todo: newTaskText, done: false))
        ToDoList.saveToDo(lst: listItems)
        DispatchQueue.main.async {
            newTaskText = ""
        }
    }
    
    // toggle if a list element is being used
    func toggleDone(id: UUID) {
        listItems = ToDoList.getToDo()
        for i in 0..<listItems.count {
            if listItems[i].id == id {
                listItems[i] = ToDoEntry(todo: listItems[i].todo, done: !listItems[i].done)
                ToDoList.saveToDo(lst: listItems)
            }
        }
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
                    ForEach(listItems) { item in
                        HStack {
                            // task
                            Text(item.todo)
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .clipped()
                            Spacer()
                            
                            // icon for whether or not it's done
                            Button(action: {
                                toggleDone(id: item.id)
                            }) {
                                if item.done {
                                    Image(systemName: "checkmark")
                                } else {
                                    Image(systemName: "rectangle")
                                }
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
    TodoView(expanded: .constant(true))
}
