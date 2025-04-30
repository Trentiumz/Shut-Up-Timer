import SwiftUI;

struct SessionEntryView : View {
    @State private var sessionEntry: SessionEntry;
    @State private var todoEntry: ToDoEntry?;
    @EnvironmentObject var todoList: ToDoList;
    
    init(sessionEntry: SessionEntry) {
        self.sessionEntry = sessionEntry;
    }
    
    var body: some View {
        VStack {
            if let todo = todoEntry {
                Text("You locked in \(sessionEntry.timeLocked) seconds on \(sessionEntry.started) to do \(todo.todo) and \(sessionEntry.success ? "succeeded" : "failed")")
                    .padding()
                    .background(.gray)
                    .cornerRadius(10);
            } else {
                Text("You locked in \(sessionEntry.timeLocked) seconds on \(sessionEntry.started) and \(sessionEntry.success ? "succeeded" : "failed")")
                    .padding()
                    .background(.gray)
                    .cornerRadius(10);
            }
        }.task {
            if let todo = todoList.lst.first(where: { $0.id == sessionEntry.todoID }) {
                todoEntry = todo;
            } else {
                todoEntry = nil;
            }
        }
    }
}

#Preview {
    SessionEntryView(sessionEntry: SessionEntry(todoID: UUID(), started: Date(), ended: Date(), timeLocked: 10, success: true));
}
