import SwiftUI;

struct DisappointmentView : View {
    @EnvironmentObject var sessions: Sessions;

    var body: some View {
        ScrollView {
            VStack {
                ForEach(sessions.sessions) { session in
                    SessionEntryView(sessionEntry: session);
                }
            }
        }
    }
}

fileprivate struct RoastList : View {
    var text: String;
    
    init(_ text: String) {
        self.text = text;
    }
    
    var body : some View {
        ZStack(alignment: .leading) {
            FormattedImages.DisappointmentStrip(width: 300)
            FormattedImages.LeaderboardBandage(width: 80)
                .rotationEffect(Angle(degrees: 90))
                .offset(x: -35)
            HStack {
                Spacer()
                    .frame(maxWidth: 35)
                Text(text)
                    .font(FontTokens.architectsDaughter(size: 20))
                    .minimumScaleFactor(0.4)
                    .foregroundColor(ColorTokens.shade700)
                    .frame(width: 250, height: 45, alignment: .topLeading)
            }
        }
    }
}

#Preview {
    RoastList("Testing")
    // DisappointmentView().environmentObject(Sessions(sessions: []))
}
