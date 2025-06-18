import SwiftUI;

struct RoastListView: View {
    let profile: UserPublicProfileResponse?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ScrollView(.horizontal) {
                HStack {
                    if let roasts = profile?.roasts {
                        ForEach(roasts, id: \.self) { roast in
                            RoastDisplay(message: roast)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }.frame(maxWidth: .infinity)
    }
}

#Preview {
    RoastListView(profile: UserPublicProfileResponse(iq: 20, username: "hi", profile_picture: "hi", roasts: ["No ur an idiot, who has nobody that they can talk to and won't study either :(", "Goodbye Sire", "woohoo!"], hours: "2H1M", top_categories: []))
    // RoastDisplay(message: "At this point, your to-do list is fiction.")
}
