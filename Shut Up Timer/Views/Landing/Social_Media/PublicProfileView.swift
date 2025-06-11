import SwiftUI;

struct PublicProfileView : View {
    let profile: UserPublicProfileResponse;
    
    var body: some View {
        VStack(spacing: 10) {
            // Profile Picture and Username
            HStack(spacing: 30) {
                // Profile Picture
                if !profile.profile_picture.isEmpty {
                    AsyncImage(url: URL(string: profile.profile_picture)) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                    } placeholder: {
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 80, height: 80)
                    }
                } else {
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 80, height: 80)
                }
                
                VStack {
                    // Username
                    Text(profile.username)
                        .font(FontTokens.architectsDaughter(size: 30))
                        .foregroundColor(ColorTokens.shade700)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity)
                        .minimumScaleFactor(0.01)
                    if let lastLogin = profile.last_login {
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
                    Text(profile.hours)
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
                    let categoryNames = profile.top_categories.prefix(2);
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
                    Text("\(profile.iq)")
                        .font(FontTokens.architectsDaughter(size: 20))
                        .foregroundColor(ColorTokens.shade700)
                    Spacer()
                }
                .frame(height: 70)
                
                Spacer()
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
    PublicProfileView(profile:UserPublicProfileResponse(iq: 10, username: "Taboo", profile_picture: "", roasts: [], hours: "3H1M", last_login: nil, top_categories: []))
}
