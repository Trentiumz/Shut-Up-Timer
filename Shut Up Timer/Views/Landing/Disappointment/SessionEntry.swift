import SwiftUI;

struct SessionEntryView : View {
    private var sessionEntry: SessionEntry;
    
    init(sessionEntry: SessionEntry) {
        self.sessionEntry = sessionEntry;
    }
    
    var body: some View {
        Text("You locked in \(sessionEntry.timeLocked) seconds on \(sessionEntry.started) and \(sessionEntry.success ? "succeeded" : "failed")");
            .padding()
            .background(.gray)
            .cornerRadius(10)
    }
}

#Preview {
    LBRowView(sessionEntry: SessionEntry(todoID: UUID(), started: Date(), ended: Date(), timeLocked: 10, success: true));
}
