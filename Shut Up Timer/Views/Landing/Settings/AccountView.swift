import SwiftUI;
import _PhotosUI_SwiftUI

struct AccountView : View {
    @EnvironmentObject var settings: Settings;
    @EnvironmentObject var credManager: CredManager;
    @EnvironmentObject var router: AppRouter;
    @Environment(CurUser.self) var curUser;
    @State private var friends: [FriendProfileResponse] = [];
    
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
                            LocalUserInfoView()
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
                    
                    SettingsView()
                }.padding(.horizontal)
            }
        }
        .onAppear {
            curUser.refresh()
            updateFriends()
        }
        .onChange(of: credManager.session) {
            curUser.refresh()
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

/// A copy of User Info View with options for editing things
struct LocalUserInfoView : View {
    @EnvironmentObject var sessions: Sessions;
    @EnvironmentObject var credManager: CredManager;
    @Environment(ToDoListV2.self) var todoList;
    @Environment(CurUser.self) var curUser;
    
    @State private var pickedImage: PhotosPickerItem?
    @State var showFailAlert: Bool = false
    
    @State var uploading: Bool = false
    
    var body: some View {
        VStack(spacing: 10) {
            if let pp = curUser.userPublicProfile {
                // Profile Picture and Username
                HStack(spacing: 30) {
                    // Profile Picture
                    PhotosPicker(
                        selection: $pickedImage,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        PFPDisplay(url: pp.profile_picture, width: 80, height: 80)
                            .opacity(uploading ? 0.5 : 1)
                    }
                    .onChange(of: pickedImage) { oldVal, newVal in
                        Task {
                            await MainActor.run {
                                withAnimation {
                                    uploading = true;
                                }
                            }
                            if let data = try? await newVal?.loadTransferable(type: Data.self),
                               let image = UIImage(data: data)
                            {
                                let success = await credManager.uploadPFP(image: image)
                                if success {
                                    curUser.refresh()
                                } else {
                                    showFailAlert = true
                                }
                            }
                            await MainActor.run {
                                withAnimation {
                                    uploading = false;
                                }
                            }
                        }
                    }
                    .alert("Oops!", isPresented: $showFailAlert) {
                        Button("OK", role: .cancel) {}
                    } message: {
                        Text("We couldn't update your profile picture")
                    }
                    
                    VStack {
                        // Username
                        Text(pp.username)
                            .font(FontTokens.architectsDaughter(size: 30))
                            .foregroundColor(ColorTokens.shade700)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity)
                            .minimumScaleFactor(0.01)
                        if let lastLogin = pp.last_login {
                            Text("Last Login: \(lastLogin)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    Spacer()
                }
                
                // Stats
                HStack(spacing: 20) {
                    // Seconds
                    VStack {
                        Text("Hours")
                            .font(FontTokens.architectsDaughter(size: 20))
                            .foregroundColor(ColorTokens.shade600)
                        Text("\(sessions.getTotalTimeLocked())")
                            .font(FontTokens.architectsDaughter(size: 20))
                            .foregroundColor(ColorTokens.shade700)
                        Spacer()
                    }
                    .frame(height: 70)
                    
                    // Categories
                    VStack {
                        Text("Categories")
                            .font(FontTokens.architectsDaughter(size: 20))
                            .foregroundColor(ColorTokens.shade600)
                        let categoryNames = sessions.getTopCategoryStrings(toDoList: todoList);
                        Text(categoryNames.joined(separator: ", "))
                            .font(FontTokens.architectsDaughter(size: 20))
                            .foregroundColor(ColorTokens.shade700)
                        Spacer()
                    }
                    .frame(height: 70)
                    
                    // IQ
                    VStack {
                        Text("IQ")
                            .font(FontTokens.architectsDaughter(size: 20))
                            .foregroundColor(ColorTokens.shade600)
                        Text("\(sessions.getIQ())")
                            .font(FontTokens.architectsDaughter(size: 20))
                            .foregroundColor(ColorTokens.shade700)
                        Spacer()
                    }
                    .frame(height: 70)
                    
                    Spacer()
                }
            } else {
                Text("Log in to view your profile")
            }
        }
        .padding(.leading, 20)
        .cornerRadius(15)
        .frame(width: 320, height: 190)
        .background(
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 340, height: 190, alignment: .trailing)
                .background(
                    ImageAssets.onboardingHello68
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 370, height: 220.0034637451172, alignment: .bottom)
                        .clipped()
                        .offset(x: -10, y: 20)
                )
                .rotationEffect(Angle(degrees: -178))
        )
    }
}

#Preview {
    let credManager = CredManager()
    AccountView()
        .environmentObject(AppRouter())
        .environmentObject(SettingsLoader.loadSettings(onUpdate: {_ in }))
        .environmentObject(SessionsLoader.loadSessions(onUpdate: {_ in }))
        .environment(ToDoLoader.getToDo())
        .environmentObject(credManager)
        .environment(CurUser(credManager: credManager))
}
