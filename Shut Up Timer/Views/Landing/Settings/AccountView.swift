import SwiftUI;

struct AccountView : View {
    @EnvironmentObject var settings: Settings;
    @EnvironmentObject var credManager: CredManager;
    @EnvironmentObject var router: AppRouter;
    @State private var userPublicProfile: UserPublicProfileResponse? = nil;
    @State private var userProfile: UserProfileResponse? = nil;
    @State private var friends: [FriendProfileResponse] = [];
    
    func updateUserProfile() {
        userPublicProfile = nil;
        userProfile = nil;
        Task {
            do {
                if let userId = credManager.session?.user.id {
                    // Get public profile
                    let publicProfile: [UserPublicProfileResponse] = try await credManager.supabaseClient.rpc("get_user_public_profile", params: ["user_id": userId]).execute().value
                    // Get private profile
                    let privateProfile: [UserProfileResponse] = try await credManager.supabaseClient.rpc("get_profile").execute().value
                    
                    await MainActor.run {
                        userPublicProfile = publicProfile[0]
                        userProfile = privateProfile[0]
                    }
                }
            } catch {
                print("Error fetching user profiles: \(error)")
            }
        }
    }
    
    func updateFriends() {
        Task {
            do {
                let friendProfiles: [FriendProfileResponse] = try await credManager.supabaseClient.rpc("get_friend_profiles").execute().value
                await MainActor.run {
                    friends = friendProfiles
                }
            } catch {
                print("Error fetching friends: \(error)")
            }
        }
    }
    
    func removeFriend(_ friendId: UUID) {
        Task {
            do {
                try await credManager.supabaseClient.rpc("remove_friend", params: ["other_id": friendId]).execute()
                await MainActor.run {
                    updateFriends()
                }
            } catch {
                print("Error removing friend: \(error)")
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack {
                UserInfoView(userPublicProfile: userPublicProfile)
                
                if credManager.loggedIn {
                    FriendsList(
                        friends: friends,
                        removeFriend: removeFriend
                    )
                }
                
                Text("Settings")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top)
                
                SettingsView(
                    userPublicProfile: $userPublicProfile,
                    userProfile: $userProfile,
                    updateUserProfile: updateUserProfile
                )
            }
        }
        .onAppear {
            updateUserProfile()
            updateFriends()
        }
        .onChange(of: credManager.session) {
            updateUserProfile()
            updateFriends()
        }
    }
}

struct FriendsList : View {
    @EnvironmentObject var credManager: CredManager
    var friends: [FriendProfileResponse]
    var removeFriend: (UUID) -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Friends")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(friends, id: \.friend_user_id) { friend in
                        FriendCard(
                            friend: friend,
                            removeFriend: removeFriend
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct FriendCard : View {
    var friend: FriendProfileResponse
    var removeFriend: (UUID) -> Void

    var body: some View {
        VStack {
            if !friend.friend_profile_picture.isEmpty {
                AsyncImage(url: URL(string: friend.friend_profile_picture)) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                } placeholder: {
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 60, height: 60)
                }
            } else {
                Circle()
                    .fill(Color.gray)
                    .frame(width: 60, height: 60)
            }
            
            Text(friend.friend_username)
                .font(.headline)
            
            Text("IQ: \(friend.friend_iq)")
                .font(.subheadline)
            
            Button(action: {
                removeFriend(friend.friend_user_id)
            }) {
                Image(systemName: "person.fill.xmark")
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

#Preview {
    AccountView();
}
