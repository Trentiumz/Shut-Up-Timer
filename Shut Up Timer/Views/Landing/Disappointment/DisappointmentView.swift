import SwiftUI;

struct DisappointmentView : View {
    @EnvironmentObject var sessions: Sessions;

    var body: some View {
        ForEach(sessions.sessions) { session in
            SessionEntryView(sessionEntry: session);
        }
    }
}

#Preview {
    DisappointmentView();
}
