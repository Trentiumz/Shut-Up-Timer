import SwiftUI;

struct SessionEntryView : View {
    @State private var sessionEntry: SessionEntry;
    @EnvironmentObject var todoList: ToDoList;
    
    init(sessionEntry: SessionEntry) {
        self.sessionEntry = sessionEntry;
    }

    func getTaskName(todoID: UUID) -> String {
        if let todo = todoList.lst.first(where: { $0.id == todoID}) {
            return todo.todo;
        } else {
            return "unknown";
        }
    }
    
    var body: some View {
        VStack {
            Text("You locked in \(sessionEntry.timeLocked) seconds on \(sessionEntry.started) and \(sessionEntry.success ? "succeeded" : "failed"). \(roast = sessionEntry.roast ? "Your roast is \(roast)" : "")")
                .padding()
            BulletListView(items: sessionEntry.tasks.map{ "Did \(getTaskName(todoID: $0.todoID)) for \($0.timeIn) seconds"})
        }.background(.gray)
        .cornerRadius(10);
    }
}

struct BulletListView: View {
    let items: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(items, id: \.self) { item in
                Text("• \(item)")
            }
        }
        .padding()
    }
}

#Preview {
    SessionEntryView(sessionEntry: SessionEntry(tasks: [], started: Date(), ended: Date(), timeLocked: 10, success: true));
}
