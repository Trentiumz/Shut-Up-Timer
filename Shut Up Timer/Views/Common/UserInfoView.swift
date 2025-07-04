import SwiftUI;

struct UserInfoView : View {
    var iq: Double
    var username: String
    var profile_picture: String
    var roasts: [String]
    var hours: String
    var last_login: Date?
    var top_categories: [String]
    
    init(iq: Double, username: String, profile_picture: String, roasts: [String], hours: String, last_login: Date? = nil, top_categories: [String]) {
        self.iq = iq
        self.username = username
        self.profile_picture = profile_picture
        self.roasts = roasts
        self.hours = hours
        self.last_login = last_login
        self.top_categories = top_categories
    }
    
    init(userResponse: UserPublicProfileResponse) {
        self.iq = Double(userResponse.iq);
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
                PFPDisplay(url: profile_picture, width: 80, height: 80)
                
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
            FormattedImages.UserInfoBackground(width: 340)
        )
    }
}

struct PFPDisplay : View {
    var url: String;
    var width: CGFloat;
    var height: CGFloat;
    
    var body: some View {
        Group {
            if !url.isEmpty {
                AsyncImage(url: URL(string: url)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: width, height: height)
                        .clipShape(Circle())
                } placeholder: {
                    Circle()
                        .fill(Color.gray)
                        .frame(width: width, height: height)
                }
            } else {
                Circle()
                    .fill(Color.gray)
                    .frame(width: width, height: height)
            }
        }
    }
}
