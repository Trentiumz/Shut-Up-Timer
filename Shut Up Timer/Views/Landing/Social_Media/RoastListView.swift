import SwiftUI;

struct RoastListView: View {
    let profile: UserPublicProfileResponse?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let roasts = profile?.roasts {
                ForEach(roasts, id: \.self) { roast in
                    Text(roast)
                        .foregroundColor(.primary)
                        .padding(.vertical, 4)
                }
            } 
        }
        .padding()
    }
}