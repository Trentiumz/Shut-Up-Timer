import SwiftUI;
import CoreData

struct SessionEntryView : View {
    @ObservedObject var session: Session;
    @Environment(\.managedObjectContext) private var viewContext
    
    // Fetch active todos for category name lookup
    @FetchRequest(
        entity: Todo.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Todo.created, ascending: false)],
        predicate: NSPredicate(format: "active == YES")
    ) private var activeTodos: FetchedResults<Todo>
    
    init(session: Session) {
        self.session = session;
    }

    func getTaskName(todoID: UUID) -> String {
        if let todo = activeTodos.first(where: { $0.id == todoID}) {
            return todo.todo ?? "unknown";
        } else {
            return "unknown";
        }
    }
    
    func roastMessage(_ roast: String?) -> String {
        if let roast = roast {
            return "Your roast is \"\(roast)\""
        } else {
            return ""
        }
    }
    
    var body: some View {
        VStack {
            Text("You locked in \(Int(session.timeLocked)) seconds on \(session.started?.formatted() ?? "unknown") and \(session.success ? "succeeded" : "failed"). \(roastMessage(session.roast))")
                .padding()
            BulletListView(items: session.taskLogsArray.map{ "Did \(getTaskName(todoID: $0.todo?.id ?? UUID())) for \(Int($0.timeIn)) seconds"})
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
    let context = PersistenceController.shared.container.viewContext
    let session = Session(context: context)
    session.timeLocked = 10
    session.plannedTime = 20 
    session.success = true
    session.started = Date()
    
    return SessionEntryView(session: session)
        .environment(\.managedObjectContext, context)
}
