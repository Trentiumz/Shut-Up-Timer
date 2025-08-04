import SwiftUI;
import _PhotosUI_SwiftUI

struct AccountView : View {
    @EnvironmentObject var settings: Settings;
    @EnvironmentObject var credManager: CredManager;
    @EnvironmentObject var router: AppRouter;
    @EnvironmentObject var sessions: SessionLoader;
    @EnvironmentObject var curUser: CurUser
    @State private var friends: [FriendProfileResponse] = [];
    @EnvironmentObject var postLoader: PostLoader;
    @Environment(\.managedObjectContext) private var viewContext
    
    func updateFriends() {
        Task {
            do {
                let friendProfiles: [FriendProfileResponse] = try await credManager.supabaseClient.rpc("get_friend_profiles").execute().value
                await MainActor.run {
                    friends = friendProfiles
                }
            } catch {
                print("Error fetching friends: \(error)")
            }
        }
    }
    
    func removeFriend(_ friendId: UUID) {
        Task {
            do {
                try await credManager.supabaseClient.rpc("remove_friend", params: ["other_id": friendId]).execute()
                await MainActor.run {
                    updateFriends()
                }
            } catch {
                print("Error removing friend: \(error)")
            }
        }
    }
    
    /// posts albums: [(StringWriting, Month, Year)]
    var postAlbums: [(String, Int, Int)] {
        // Convert posts to PostInfo objects
        let postInfos = postLoader.posts.map { post in
            post.toLocalPostInfo(currentUser: curUser, context: viewContext)
        }
        
        // Get all posts with dates
        let postsWithDates = postInfos.compactMap { postInfo in
            postInfo.time
        }
        
        // If no posts, return current month
        if postsWithDates.isEmpty {
            let now = Date()
            return [getMonthRep(now)]
        }
        
        // Get earliest date and corresponding month
        let earliest = postsWithDates.min(by: <) ?? Date()
        let calendar = Calendar.current
        let now = Date()
        var current = startOfMonth(earliest)
        var dates: [Date] = []
        
        // add all months up to current
        while current <= now {
            dates.append(current)
            current = calendar.date(byAdding: .month, value: 1, to: current)!
        }
        
        // this is from earliest to current, now reverse it!
        return dates.map { getMonthRep($0) }.reversed()
    }
    
    func getMonthRep(_ date: Date) -> (String, Int, Int) {
        let month = Calendar.current.component(.month, from: date)
        let year = Calendar.current.component(.year, from: date)
        let formatter = DateFormatter()
        return ("\(formatter.monthSymbols[month - 1]) \(year)", month, year)
    }
    
    func startOfMonth(_ date: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: date)
        if let date = calendar.date(from: components) {
            return date
        } else {
            print("Failed to get start of month for \(date)")
            return Date()
        }
    }
    
    var body: some View {
        ZStack {
            Background()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            ScrollView {
                VStack {
                    Spacer()
                        .frame(maxHeight: 30)
                    
                    if credManager.loggedIn {
                        VStack(spacing: 20) {
                            LocalUserInfoView()
                            
                            // TODO: Add back Posts Section
//                            HStack {
//                                SectionStripe("Posts >")
//                                Spacer()
//                            }.padding(.horizontal, 20)
//                            
//                            ViewThatFits {
//                                HorizontalScroller(data: postAlbums, itemWidth: 140, numItems: 2) { album in
//                                    Button(action: { router.toPostView(month: album.1, year: album.2) }) {
//                                        FormattedImages.DisappointmentBook(album.0, width: 140)
//                                    }
//                                }
//                                HorizontalScroller(data: postAlbums, itemWidth: 120, numItems: 2) { album in
//                                    Button(action: { router.toPostView(month: album.1, year: album.2) }) {
//                                        FormattedImages.DisappointmentBook(album.0, width: 120)
//                                    }
//                                }
//                            }
//                            .edgesIgnoringSafeArea(.horizontal)
                            
                            HStack {
                                SectionStripe("Friends >")
                                Spacer()
                            }.padding(.horizontal, 20)
                            FriendsListView(friends, removeFriend: removeFriend)
                        }
                    }
                    
                    HStack {
                        AccountView.SectionStripe("Settings")
                        Spacer()
                    }.padding(.horizontal, 20)
                    
                    SettingsView()
                }.padding(.horizontal)
            }
        }
        .onAppear {
            curUser.refresh()
            updateFriends()
        }
        .onChange(of: credManager.session) { _ in
            curUser.refresh()
            updateFriends()
        }
    }
    
    struct SectionStripe : View {
        var text: String;
        
        init(_ text: String){
            self.text = text;
        }
        
        var body : some View {
            ZStack {
                FormattedImages.FriendCodeStripe(width: 200);
                Text(text)
                    .font(FontTokens.architectsDaughter(size: 20))
                    .foregroundColor(ColorTokens.shade100)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .frame(width: 170, alignment: .topLeading)
            }
        }
    }
}

/// A copy of User Info View with options for editing things
struct LocalUserInfoView : View {
    @EnvironmentObject var sessions: SessionLoader;
    @EnvironmentObject var credManager: CredManager;
    @EnvironmentObject var curUser: CurUser
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var pickedImage: PhotosPickerItem?
    @State var showFailAlert: Bool = false
    
    @State var uploading: Bool = false
    
    var body: some View {
        VStack(spacing: 10) {
            if let pp = curUser.userPublicProfile {
                // Profile Picture and Username
                HStack(spacing: 30) {
                    // Profile Picture
                    PhotosPicker(
                        selection: $pickedImage,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        PFPDisplay(url: pp.profile_picture, width: 80, height: 80)
                            .opacity(uploading ? 0.5 : 1)
                    }
                    .onChange(of: pickedImage) { newVal in
                        Task {
                            await MainActor.run {
                                withAnimation {
                                    uploading = true;
                                }
                            }
                            if let data = try? await newVal?.loadTransferable(type: Data.self),
                               let image = UIImage(data: data)
                            {
                                let success = await credManager.uploadPFP(image: image)
                                if success {
                                    curUser.refresh()
                                } else {
                                    showFailAlert = true
                                }
                            }
                            await MainActor.run {
                                withAnimation {
                                    uploading = false;
                                }
                            }
                        }
                    }
                    .alert("Oops!", isPresented: $showFailAlert) {
                        Button("OK", role: .cancel) {}
                    } message: {
                        Text("We couldn't update your profile picture")
                    }
                    
                    VStack {
                        // Username
                        Text(pp.username)
                            .font(FontTokens.architectsDaughter(size: 30))
                            .foregroundColor(ColorTokens.shade700)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity)
                            .minimumScaleFactor(0.01)
                        if let lastLogin = pp.last_login {
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
                        Text(String(format: "%.2f", Session.getTotalTimeLocked(context: viewContext) / 3600))
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
                        let categoryNames = Session.getTopCategoryStrings(context: viewContext);
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
                        Text("\(Session.getTotalIQ(context: viewContext))")
                            .font(FontTokens.architectsDaughter(size: 20))
                            .foregroundColor(ColorTokens.shade700)
                        Spacer()
                    }
                    .frame(height: 70)
                    
                    Spacer()
                }
            } else {
                Text("Log in to view your profile")
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

#Preview {
    let credManager = CredManager()
    AccountView()
        .environmentObject(AppRouter())
        .environmentObject(SettingsLoader.loadSettings())
        .environmentObject(CredManager())
        .environmentObject(CurUser(credManager: credManager))
}
