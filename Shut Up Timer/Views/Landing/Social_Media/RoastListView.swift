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

struct RoastDisplay : View {
    let message: String;
    var body : some View {
        ZStack(alignment: .top) {
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 141, height: 141)
                .background(
                    ImageAssets.roastBackground
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 180, height: 180)
                        .clipped()
                )
            Text(message)
                .font(FontTokens.architectsDaughter(size: 28))
                .minimumScaleFactor(0.5)
                .foregroundColor(ColorTokens.shade100)
                .frame(width: 90, alignment: .topLeading)
                .frame(maxHeight: 80)
                .padding(.top, 15)
        }
    }
}

#Preview {
    RoastListView(profile: UserPublicProfileResponse(iq: 20, username: "hi", profile_picture: "hi", roasts: ["No ur an idiot, who has nobody that they can talk to and won't study either :(", "Goodbye Sire", "woohoo!"], hours: "2H1M", top_categories: []))
    // RoastDisplay(message: "At this point, your to-do list is fiction.")
}
