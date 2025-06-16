import SwiftUI

struct FriendsListView : View {
    private var chunkedFriends: [[(pfp: String, username: String)]];
    
    init(_ friends: [FriendProfileResponse]) {
        chunkedFriends = Utils.chunked(friends.map({ profile in
            (pfp: profile.friend_profile_picture, username: profile.friend_username)
        }))
    }
    
    var body : some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(Array(chunkedFriends.enumerated()), id: \.offset) { index, chunk in
                    SingleFriendsListView(friends: chunk)
                }
            }
        }
    }
    
    struct SingleFriendsListView : View {
        var friends: [(pfp: String, username: String)];
        
        var body : some View {
            ZStack {
                FormattedImages.LinedImageBackground(width: 300)
                
                // two rows of three each
                VStack {
                    HStack(spacing: 20) {
                        Spacer()
                            .frame(maxWidth: 30)
                        ForEach(0..<3, id: \.self){ ind in
                            SingleFriendView(friend: ind < friends.count ? friends[ind] : nil)
                        }
                        Spacer()
                    }
                    HStack(spacing: 0) {
                        Spacer()
                            .frame(maxWidth: 30)
                        ForEach(3..<6, id: \.self){ ind in
                            SingleFriendView(friend: ind < friends.count ? friends[ind] : nil)
                        }
                        Spacer();
                    }
                    Spacer()
                }.frame(width: 280, height: 180, alignment: .leading)
            }
        }
    }
    
    struct SingleFriendView : View {
        var friend: (pfp: String, username: String)?;
        
        var body : some View {
            if let friend = friend {
                VStack(spacing: 0) {
                    AsyncImage(url: URL(string: friend.pfp)) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                    } placeholder: {
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 50, height: 50)
                    }
                    Text(friend.username)
                        .font(FontTokens.architectsDaughter(size: 30))
                        .minimumScaleFactor(0.4)
                        .multilineTextAlignment(.center)
                        .frame(width: 60, height: 30)
                        .foregroundColor(ColorTokens.shade700)
                        .clipped()
                }.frame(width: 60, height: 80)
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
    FriendsListView.SingleFriendsListView(friends: [(pfp: "Bob", username: "Trent"), (pfp: "Bob", username: "Trent"), (pfp: "Bob", username: "Trent"), (pfp: "Bob", username: "Trent")])
}
