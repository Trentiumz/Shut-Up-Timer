import SwiftUI;

struct UserInfoView : View {
    @EnvironmentObject var sessions: Sessions;
    @EnvironmentObject var todoList: ToDoList;
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
                
                // Username
                if let profile = userPublicProfile {
                    Text(profile.username)
                        .font(.title)
                        .fontWeight(.bold)
                }
            }
            
            // Stats
            HStack(spacing: 20) {
                // Seconds
                VStack {
                    Text("Seconds")
                        .font(.headline)
                    Text("\(sessions.getTotalTimeLocked())")
                        .font(.title2)
                }
                
                // Categories
                VStack {
                    Text("Categories")
                        .font(.headline)
                    let topCategories = sessions.getTopCategories().prefix(2)
                    let categoryNames = topCategories.map { category in
                        todoList.uuidToEntry(category.todoID)?.todo ?? "Unknown"
                    }
                    Text(categoryNames.joined(separator: ", "))
                        .font(.subheadline)
                }
                
                // IQ
                VStack {
                    Text("IQ")
                        .font(.headline)
                    Text("\(sessions.getIQ())")
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