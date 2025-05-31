import SwiftUI;

struct SocialMediaView: View {
    let credManager: CredentialManager // assuming you inject this
    @State private var profiles: [UserPublicProfileResponse] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if profiles.isEmpty {
                Text("No roasts available.")
                    .foregroundColor(.secondary)
            } else {
                ForEach(profiles, id: \.self) { profile in
                    PublicProfileView(userPublicProfile: profile)
                    RoastListView(profile: profile)
                }
            }
        }
        .padding()
        .onAppear {
            Task {
                await fetchFriendsAndProfiles()
            }
        }
    }

    func fetchFriendsAndProfiles() async {
        do {
            let friends: [FriendsResponse] = try await credManager.supabaseClient
                .rpc("get_friends")
                .execute()
                .value
            
            for friend in friends {
                let id = friend.id // adjust this to match actual key
                let userProfile: [UserPublicProfileResponse] = try await credManager.supabaseClient
                    .rpc("get_user_public_profile", params: ["id": id])
                    .execute()
                    .value
                
                // assuming the RPC returns a single-element list
                if let profile = userProfile.first {
                    await MainActor.run {
                        profiles.append(profile)
                    }
                }
            }
        } catch {
            print("Error fetching profiles: \(error)")
        }
    }
}