import SwiftUI;

struct LeaderboardView : View {
    private var data = [LBEntry(name: "Bob", pts: 50), LBEntry(name: "Fred", pts: 10)];
    
    var body: some View {
        VStack() {
            ForEach(data) { user in
                LBRowView(name: user.name, pts: user.pts);
            }
        }
    }
}

#Preview {
    LeaderboardView();
}
