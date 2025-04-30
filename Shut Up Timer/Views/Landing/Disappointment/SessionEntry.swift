import SwiftUI;

struct SessionEntryView : View {
    private var sessionEntry: SessionEntry;
    private var todoEntry: ToDoEntry?;
    
    init(sessionEntry: SessionEntry) {
        self.sessionEntry = sessionEntry;
        if let todo = ToDoList.getToDo().first(where: { $0.id == sessionEntry.todoID }) {
            todoEntry = todo;
        } else {
            todoEntry = nil;
        }
    }
    
    var body: some View {
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
    }
}

#Preview {
    SessionEntryView(sessionEntry: SessionEntry(todoID: UUID(), started: Date(), ended: Date(), timeLocked: 10, success: true));
}
