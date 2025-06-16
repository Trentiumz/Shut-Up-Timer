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
                        if privateProfile.count > 0 && publicProfile.count > 0 {
                            userPublicProfile = publicProfile[0]
                            userProfile = privateProfile[0]	
                        }
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
        ZStack {
            Background()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            ScrollView {
                VStack {
                    Spacer()
                        .frame(maxHeight: 30)
                    
                    if credManager.loggedIn {
                        VStack(spacing: 20) {
                            LocalUserInfoView(userPublicProfile: userPublicProfile)
                            HStack {
                                SectionStripe("Friends >")
                                Spacer()
                            }.padding(.horizontal, 20)
                            FriendsListView(friends, removeFriend: removeFriend)
                        }
                    }
                    
                    HStack {
                        AccountView.SectionStripe("Settings")
                        Spacer()
                    }.padding(.horizontal, 20)
                    
                    SettingsView(
                        userPublicProfile: $userPublicProfile,
                        userProfile: $userProfile,
                        updateUserProfile: updateUserProfile
                    )
                }.padding(.horizontal)
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
    
    struct SectionStripe : View {
        var text: String;
        
        init(_ text: String){
            self.text = text;
        }
        
        var body : some View {
            ZStack {
                FormattedImages.FriendCodeStripe(width: 200);
                Text(text)
                    .font(FontTokens.architectsDaughter(size: 20))
                    .foregroundColor(ColorTokens.shade100)
                    .frame(width: 96.88741, alignment: .topLeading)
            }
        }
    }
}

struct LocalUserInfoView : View {
    @EnvironmentObject var sessions: Sessions;
    @EnvironmentObject var credManager: CredManager;
    @EnvironmentObject var todoList: ToDoList
    var userPublicProfile: UserPublicProfileResponse?;
    
    var body : some View {
        UserInfoView(iq: sessions.getIQ(), username: userPublicProfile?.username ?? "", profile_picture: userPublicProfile?.profile_picture ?? "", roasts: sessions.getRoasts(), hours: "\(sessions.getTotalTimeLocked())", top_categories: sessions.getTopCategoryStrings(toDoList: todoList))
    }
}

#Preview {
    AccountView()
        .environmentObject(AppRouter())
        .environmentObject(SettingsLoader.loadSettings(onUpdate: {_ in }))
        .environmentObject(SessionsLoader.loadSessions(onUpdate: {_ in }))
        .environmentObject(ToDoLoader.getToDo(onUpdate: { _ in }))
        .environmentObject(CredManager())
}
