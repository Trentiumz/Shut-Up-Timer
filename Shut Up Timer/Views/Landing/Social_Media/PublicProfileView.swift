import SwiftUI;

struct PublicProfileView : View {
    let userPublicProfile: UserPublicProfileResponse?;
    
    var body: some View {
        VStack(spacing: 20) {
            // Profile Picture and Username
            HStack(spacing: 15) {
                // Profile Picture
                if let profile = userPublicProfile, !profile.profile_picture.isEmpty {
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
                    if let profile = userPublicProfile {
                        Text(profile.username)
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    if lastLogin = profile.last_login {
                        Text("Last Login: \(lastLogin)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            // Stats
            HStack(spacing: 20) {
                // Seconds
                VStack {
                    Text("Total Time")
                        .font(.headline)
                    Text("\(profile.hours)")
                        .font(.title2)
                }
                
                // Categories
                VStack {
                    Text("Categories")
                        .font(.headline)
                    let categoryNames = profile.top_categories.prefix(2);
                    Text(categoryNames.joined(separator: ", "))
                        .font(.subheadline)
                }
                
                // IQ
                VStack {
                    Text("IQ")
                        .font(.headline)
                    Text("\(profile.iq)")
                        .font(.title2)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
        .frame(maxWidth: .infinity)
    }
} 