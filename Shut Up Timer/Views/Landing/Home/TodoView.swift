import SwiftUI;

struct TodoView : View {
    @Binding var expanded: Bool;
    @State private var listItems: [ToDoEntry];
    @State private var newTaskText: String;
    
    init(expanded: Binding<Bool>) {
        _expanded = expanded;
        newTaskText = "";
        listItems = ToDoList.getToDo()
    }
    
    func addTask() {
        listItems = ToDoList.getToDo()
        listItems.append(ToDoEntry(todo: newTaskText, done: false))
        ToDoList.saveToDo(lst: listItems)
        DispatchQueue.main.async {
            newTaskText = ""
        }
    }
    
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
            withAnimation {
                expanded.toggle()
            }
        }) {
            ScrollView {
                VStack {
                    ForEach(listItems) { item in
                        HStack {
                            Text(item.todo)
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .clipped()
                            Spacer()
                            
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
