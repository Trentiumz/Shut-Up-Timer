import SwiftUI;

struct TopBarView : View {
    @EnvironmentObject var sessions: Sessions;
    @EnvironmentObject var router: AppRouter;

    var body: some View {
        HStack{
            Image(systemName: "star.fill")
                .font(.system(size: 32))
            Spacer()
            
            Text("IQ: \(sessions.getIQ())")
                .font(.system(size: 32))
            
            Spacer()
            
            Button(action: {
                router.toInviteFriends();
                // Add your action here
            }) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 32))
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding()
        .background(Color(red: 0.9, green: 0.9, blue: 0.9))
    }
}

#Preview {
    VStack {
        TopBarView()
        Spacer()
    }
}
