import SwiftUI

struct FriendsListView : View {
    private var chunkedFriends: [[(pfp: String, username: String, id: UUID)]]
    var removeFriend: (UUID)->Void
    
    init(_ friends: [FriendProfileResponse], removeFriend: @escaping (UUID) -> Void) {
        chunkedFriends = Utils.chunked(friends.map({ profile in
            (pfp: profile.friend_profile_picture, username: profile.friend_username, id: profile.friend_user_id)
        }))
        self.removeFriend = removeFriend;
    }
    
    var body : some View {
        ScrollView(.horizontal) {
            if chunkedFriends.isEmpty{
                ZStack(alignment: .top) {
                    FormattedImages.LinedImageBackground(width: 300)
                    
                    Text("No Friends Yet!")
                        .font(FontTokens.architectsDaughter(size: 25))
                        .foregroundColor(ColorTokens.shade700)
                        .padding()
                }
            } else {
                HStack {
                    ForEach(Array(chunkedFriends.enumerated()), id: \.offset) { index, chunk in
                        SingleFriendsListView(friends: chunk, removeFriend: removeFriend)
                    }
                }
            }
        }.padding(.horizontal, 20)
    }
    
    struct SingleFriendsListView : View {
        var friends: [(pfp: String, username: String, id: UUID)];
        var removeFriend: (UUID)->Void;
        
        var body : some View {
            ZStack {
                FormattedImages.LinedImageBackground(width: 300)
                
                // two rows of three each
                VStack {
                    HStack(spacing: 20) {
                        Spacer()
                            .frame(maxWidth: 30)
                        ForEach(0..<3, id: \.self){ ind in
                            SingleFriendView(friend: ind < friends.count ? friends[ind] : nil, onRemove: {
                                if ind < friends.count {
                                    removeFriend(friends[ind].id)
                                }
                            })
                        }
                        Spacer()
                    }
                    HStack(spacing: 0) {
                        Spacer()
                            .frame(maxWidth: 30)
                        ForEach(3..<6, id: \.self){ ind in
                            SingleFriendView(friend: ind < friends.count ? friends[ind] : nil, onRemove: {
                                if ind < friends.count {
                                    removeFriend(friends[ind].id)
                                }
                            })
                        }
                        Spacer();
                    }
                    Spacer()
                }
                .frame(width: 280, height: 180, alignment: .leading)
            }
        }
    }
    
    struct SingleFriendView : View {
        var friend: (pfp: String, username: String, id: UUID)?;
        var onRemove: () -> Void;
        
        var body : some View {
            if let friend = friend {
                VStack(spacing: 0) {
                    PFPDisplay(url: friend.pfp, width: 50, height: 50)

                    Text(friend.username)
                        .font(FontTokens.architectsDaughter(size: 30))
                        .minimumScaleFactor(0.4)
                        .multilineTextAlignment(.center)
                        .frame(width: 60, height: 30)
                        .foregroundColor(ColorTokens.shade700)
                        .clipped()
                }
                .frame(width: 60, height: 80)
                .contextMenu {
                    Button(role: .destructive) {
                        onRemove();
                    } label: {
                        Label("Remove Friend", systemImage: "person.fill.xmark")
                    }
                }
            } else {
                Rectangle()
                    .fill(.clear)
                    .frame(width: 60, height: 80)
            }
        }
    }
}

#Preview {
    // FriendsListView.SingleFriendView(friend: (pfp: "klasdfj", username: "superlongusernamethatislong"))
    FriendsListView.SingleFriendsListView(friends: [
        (pfp: "Bob", username: "Trent", id: UUID()),
        (pfp: "Bob", username: "Trent", id: UUID()),
        (pfp: "Bob", username: "Trent", id: UUID()),
        (pfp: "Bob", username: "Trent", id: UUID())],
                                          removeFriend: { _ in })
}
