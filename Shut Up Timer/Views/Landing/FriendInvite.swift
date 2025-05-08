import SwiftUI;

struct FriendInvite : View {
    @EnvironmentObject var credManager: CredManager;
    @State private var userProfile: UserProfileResponse? = nil;
    
    func updateUserProfile() {
        userProfile = nil;
        Task {
            do {
                let privateProfile: [UserProfileResponse] = try await credManager.supabaseClient.rpc("get_profile").execute().value
                await MainActor.run {
                    userProfile = privateProfile[0]
                }
            } catch {
                print("Error fetching user profile: \(error)")
            }
        }
    }
    
    var body: some View {
        VStack {
            if credManager.loggedIn {
                if let profile = userProfile {
                    VStack(spacing: 20) {
                        Text("Your Friend Code")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        HStack {
                            Image(systemName: "person.2.fill")
                                .foregroundColor(.blue)
                                .font(.title)
                            Text(profile.friend_code)
                                .font(.title)
                                .fontWeight(.semibold)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(15)
                    }
                } else {
                    Text("Loading...")
                }
            } else {
                Text("Log in to see your friend code")
            }
        }
        .padding()
        .onAppear {
            updateUserProfile()
        }
        .onChange(of: credManager.session) {
            updateUserProfile()
        }
    }
}

#Preview {
    FriendInvite()
        .environmentObject(CredManager())
}
