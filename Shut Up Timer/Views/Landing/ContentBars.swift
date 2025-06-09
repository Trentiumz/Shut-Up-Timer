import SwiftUI;

struct TopBarView : View {
    @EnvironmentObject var credManager: CredManager;
    @EnvironmentObject var sessions: Sessions;
    @EnvironmentObject var router: AppRouter;
    
    @State private var userPublicProfile: UserPublicProfileResponse? = nil;
    
    func updateUserProfile() {
        userPublicProfile = nil;
        Task {
            do {
                if let userId = credManager.session?.user.id {
                    // Get public profile
                    let publicProfile: [UserPublicProfileResponse] = try await credManager.supabaseClient.rpc("get_user_public_profile", params: ["user_id": userId]).execute().value
                    
                    await MainActor.run {
                        if publicProfile.count > 0 {
                            userPublicProfile = publicProfile[0]
                        }
                    }
                }
            } catch {
                print("Error fetching user profiles: \(error)")
            }
        }
    }

    var body: some View {
        HStack{
            if let userPublicProfile = userPublicProfile {
                AsyncImage(url: URL(string: userPublicProfile.profile_picture)) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                        .clipShape(Circle())
                } placeholder: {
                    Image(systemName: "star.fill")
                        .font(.system(size: 32))
                }
            } else {
                Image(systemName: "star.fill")
                    .font(.system(size: 32))
            }
            Spacer()
            
            Button(action: {
                router.toInviteFriends();
                // Add your action here
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 32))
                    .foregroundStyle(ColorTokens.shade700)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding()
        .background(ColorTokens.red300)
        .onAppear {
            updateUserProfile()
        }
    }
}

enum LandingScreen {
    case home;
    case socialMedia;
    case leaderboard;
    case disappointment;
    case account;
}

struct BottomBarView : View {
    @Binding var selectedScreen: LandingScreen;
    
    init(selectedScreen : Binding<LandingScreen>) {
        self._selectedScreen = selectedScreen;
    }
    
    struct IconImage : View {
        var systemName: String;
        
        var buttonStyle = Color.black;
        var buttonSize: CGFloat = 40;
        
        init(_ systemName: String) {
            self.systemName = systemName;
        }
        
        var body : some View {
            Image(systemName: systemName)
                .foregroundStyle(buttonStyle)
                .font(.system(size: buttonSize))
        }
    }
    
    var body : some View {
        HStack {
            Button(action: {
                selectedScreen = .home
            }){
                IconImage("house.fill")
            }
            Spacer()
            Button(action: {
                selectedScreen = .socialMedia
            }){
                IconImage("person.2.fill")
            }
            Spacer()
            Button(action: {
                selectedScreen = .leaderboard
            }){
                IconImage("list.number")
            }
            Spacer()
            Button(action: {
                selectedScreen = .disappointment
            }){
                IconImage("photo.fill")
            }
            Spacer()
            Button(action: {
                selectedScreen = .account
            }){
                IconImage("gearshape.fill")
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 30)
        .frame(height: 60)
        .background(ColorTokens.red300)
    }
}

struct BarViewPreviews : PreviewProvider {
    
    struct Wrapper :  View {
        @State var selectedScreen : LandingScreen = .home;
        
        var body : some View {
            VStack {
                Spacer();
                BottomBarView(selectedScreen: $selectedScreen)
            }
        }
    }
        
    
    static var previews : some View {
        Wrapper()
    }
}
