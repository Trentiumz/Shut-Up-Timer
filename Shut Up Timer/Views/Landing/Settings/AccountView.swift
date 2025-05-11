import SwiftUI;

struct AccountView : View {
    @EnvironmentObject var settings: Settings;
    @EnvironmentObject var credManager: CredManager;
    @EnvironmentObject var router: AppRouter;
    @State private var userPublicProfile: UserPublicProfileResponse? = nil;
    @State private var userProfile: UserProfileResponse? = nil;
    
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
    
    var body: some View {
        VStack {
            UserInfoView(userPublicProfile: $userPublicProfile)
            
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
        .onAppear {
            updateUserProfile()
        }
        .onChange(of: credManager.session) {
            updateUserProfile()
        }
    }
}

#Preview {
    AccountView();
}
