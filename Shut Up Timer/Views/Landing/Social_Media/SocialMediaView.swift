import SwiftUI;

struct SocialMediaView: View {
    @EnvironmentObject var  credManager: CredManager // assuming you inject this
    @State private var profiles: [UserPublicProfileResponse] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if profiles.isEmpty {
                    Text("No friends yet!")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(profiles.indices, id: \.self) { index in
                        PublicProfileView(profile: profiles[index])
                        RoastListView(profile: profiles[index])
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
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
            
            var tempProfileList: [UserPublicProfileResponse] = []
            for friend in friends {
                let id = friend.friend_user_id // adjust this to match actual key
                let userProfile: [UserPublicProfileResponse] = try await credManager.supabaseClient
                    .rpc("get_user_public_profile", params: ["user_id": id])
                    .execute()
                    .value
                
                // assuming the RPC returns a single-element list
                if let profile = userProfile.first {
                    await MainActor.run {
                        // TODO: get rid of dependence on username
                        tempProfileList.append(profile)
                    }
                }
            }
            profiles = tempProfileList;
        } catch {
            print("Error fetching profiles: \(error)")
        }
    }
}
