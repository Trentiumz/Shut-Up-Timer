import SwiftUI

struct NotificationsView: View {
    @EnvironmentObject var notificationManager: NotificationManager
    @EnvironmentObject var router: AppRouter
    
    var body: some View {
        NotificationsListView(
            notifications: notificationManager.notifications,
            onBack: {
                notificationManager.clearNotifications();
                router.pop()
            }
        )
        .onAppear {
            print("Refreshing...")
            notificationManager.refresh()
            print("Our notifications are \(notificationManager.notifications)")
        }
    }
}

struct NotificationsListView: View {
    let notifications: [ClientNotification]
    let onBack: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            NotificationsTopBar(onBack: onBack)
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Previously")
                        .font(FontTokens.architectsDaughter(size: 28))
                        .padding(.top, 24)
                        .padding(.leading, 16)
                    ForEach(notifications) { notification in
                        NotificationCardView(notification: notification)
                            .padding(.horizontal, 12)
                            .padding(.top, 16)
                    }
                }
            }
            .background(Color.white)
        }
        .background(Color.white)
        .navigationBarBackButtonHidden(true)
    }
}

fileprivate struct NotificationsTopBar: View {
    var onBack: () -> Void
    var body: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .resizable()
                    .frame(width: 12, height: 12)
                    .foregroundColor(.white)
            }
            Spacer()
            Text("Notifications")
                .font(FontTokens.architectsDaughter(size: 24))
                .foregroundColor(.white)
            Spacer()
            Spacer().frame(width: 24) // To balance the chevron
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(ColorTokens.red300)
    }
}

fileprivate struct NotificationCardView: View {
    let notification: ClientNotification
    
    var body: some View {
        switch notification {
        case .friendReq(_, _, let pfp, let username, let created_at):
            HStack(spacing: 12) {
                PFPDisplay(url: pfp, width: 50, height: 50)
                VStack(alignment: .leading, spacing: 4) {
                    HStack() {
                        Text("Friend Request")
                            .font(FontTokens.architectsDaughter(size: 24))
                            .foregroundColor(ColorTokens.shade700)
                            .lineLimit(1)
                        Spacer()
                        Text(timeString(from: created_at))
                            .font(FontTokens.architectsDaughter(size: 16))
                            .foregroundColor(ColorTokens.shade700)
                        Circle()
                            .fill(ColorTokens.red300)
                            .frame(width: 12, height: 12)
                            .padding(.leading, 4)
                            .padding(.top, 4)
                    }
                    Text("\(username) wants to be your friend!")
                        .font(FontTokens.architectsDaughter(size: 20))
                        .minimumScaleFactor(0.7)
                        .lineLimit(2)
                        .foregroundColor(ColorTokens.shade700)
                        .padding(.top, 2)
                }
                .padding(.vertical, 8)
                .padding(.trailing, 8)
            }
            .padding(.leading, 4)
            .background(Color(.systemGray6))
            .cornerRadius(20)
        case .devResponse(let response):
            HStack(alignment: .top, spacing: 12) {
                Spacer()
                    .frame(maxWidth: 10)
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .top) {
                        Text("Feedback Response")
                            .font(FontTokens.architectsDaughter(size: 24))
                            .foregroundColor(.black)
                            .lineLimit(1)
                        Spacer()
                        Circle()
                            .fill(ColorTokens.red300)
                            .frame(width: 12, height: 12)
                            .padding(.leading, 4)
                            .padding(.top, 4)
                    }
                    Text(response)
                        .font(FontTokens.architectsDaughter(size: 20))
                        .foregroundColor(.black)
                        .padding(.top, 2)
                }
                .padding(.vertical, 8)
                .padding(.trailing, 8)
            }
            .background(Color(.systemGray6))
            .cornerRadius(20)
        }
    }
    
    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        // Sample preview for NotificationsListView
        NotificationsListView(
            notifications: [
                .friendReq(id: "1", sender_id: "user1", pfp: "", username: "Alice", created_at: Date()),
                .devResponse(response: "Your feedback has been received!"),
                .friendReq(id: "2", sender_id: "user2", pfp: "", username: "Bob_Is_Super_long_thing", created_at: Date().addingTimeInterval(-86400))
            ],
            onBack: {}
        )
        .environmentObject(AppRouter())
    }
}
