import SwiftUI;

struct UserInfoView : View {
    var iq: Int
    var username: String
    var profile_picture: String
    var roasts: [String]
    var hours: String
    var last_login: Date?
    var top_categories: [String]
    
    init(iq: Int, username: String, profile_picture: String, roasts: [String], hours: String, last_login: Date? = nil, top_categories: [String]) {
        self.iq = iq
        self.username = username
        self.profile_picture = profile_picture
        self.roasts = roasts
        self.hours = hours
        self.last_login = last_login
        self.top_categories = top_categories
    }
    
    init(userResponse: UserPublicProfileResponse) {
        self.iq = userResponse.iq;
        self.username = userResponse.username;
        self.profile_picture = userResponse.profile_picture;
        self.roasts = userResponse.roasts;
        self.hours = userResponse.hours;
        self.last_login = userResponse.last_login;
        self.top_categories = userResponse.top_categories;
    }
    
    var body: some View {
        VStack(spacing: 10) {
            // Profile Picture and Username
            HStack(spacing: 30) {
                // Profile Picture
                if !profile_picture.isEmpty {
                    AsyncImage(url: URL(string: profile_picture)) { image in
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
                    Text(username)
                        .font(FontTokens.architectsDaughter(size: 30))
                        .foregroundColor(ColorTokens.shade700)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity)
                        .minimumScaleFactor(0.01)
                    if let lastLogin = last_login {
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
                    Text(hours)
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
                    let categoryNames = top_categories.prefix(2);
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
                    Text("\(iq)")
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
