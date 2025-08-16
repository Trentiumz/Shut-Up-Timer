import SwiftUI

struct AccountPostView: View {
    @EnvironmentObject var sessions: SessionLoader
    @EnvironmentObject var postLoader: PostLoader
    @EnvironmentObject var credManager: CredManager
    @EnvironmentObject var curUser: CurUser
    @State private var selectedTab: PostTab = .month
    @State private var uploadingPosts: Set<UUID> = []
    @State private var showAlert = false
    @State private var alertMessage = ""
    @Environment(\.managedObjectContext) private var viewContext
    
    let month: Int
    let year: Int
    
    func getMonthString() -> String {
        let formatter = DateFormatter()
        return formatter.monthSymbols[month - 1]
    }
    
    func getYearString() -> String {
        return String(year)
    }

    enum PostTab: String, CaseIterable, Identifiable {
        case month = "Month"
        case all = "All"
        var id: String { self.rawValue }
    }

    // Get filtered local posts (keeps Post objects for remoteId access)
    func getFilteredLocalPosts(posts: [Post]) -> [Post] {
        let filtered = selectedTab == .month ? getMonthLocalPosts(posts: posts) : getAllLocalPosts(posts: posts)
        return filtered
    }
    
    // Get posts for current month (keeping Post objects)
    func getMonthLocalPosts(posts: [Post]) -> [Post] {
        let monthPosts = posts.filter { post in
            // Find the session associated with this post
            let postMonth = Calendar.current.component(.month, from: post.createdAt)
            let postYear = Calendar.current.component(.year, from: post.createdAt)
            return postMonth == month && postYear == year
        }
        
        // Sort by most recent first
        return monthPosts.sorted { $0.createdAt > $1.createdAt;}
    }
    
    // Get all posts (keeping Post objects)
    func getAllLocalPosts(posts: [Post]) -> [Post] {
        // Sort by most recent first
        return posts.sorted { $0.createdAt > $1.createdAt; }
    }
    
    // Retry upload for a specific post
    func retryUpload(for post: Post) {
        guard !uploadingPosts.contains(post.id) else { return }
        
        uploadingPosts.insert(post.id)
        Task {
            let postInfo = post.toLocalPostInfo(currentUser: curUser, context: viewContext)
            let remoteId = await credManager.fastAPI.createPost(postInfo)
            
            await MainActor.run {
                uploadingPosts.remove(post.id)
                if let remoteId = remoteId {
                    postLoader.updateRemoteId(post.id, remoteId: remoteId)
                } else {
                    alertMessage = "Failed to upload post. Please check your internet connection and try again."
                    showAlert = true
                }
            }
        }
    }
    
    var body: some View {
        ZStack {
            Background()
            ScrollView {
                VStack(alignment: .center, spacing: 0) {
                    
                    Spacer()
                        .frame(height: 20)
                    
                    // --- Tabs ---
                    HStack(spacing: 0) {
                        ForEach(PostTab.allCases) { tab in
                            ZStack(alignment: .center) {
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .frame(width: 120, height: 41)
                                    .background(selectedTab == tab ? ColorTokens.red300 : ColorTokens.shade300)
                                    .overlay(
                                        Rectangle()
                                            .inset(by: 1)
                                            .stroke(ColorTokens.shade700, lineWidth: 2)
                                    )
                                Text(tab.rawValue)
                                    .font(FontTokens.architectsDaughter(size: 20))
                                    .foregroundColor(selectedTab == tab ? ColorTokens.shade100 : ColorTokens.shade700)
                            }
                            .onTapGesture {
                                withAnimation {
                                    selectedTab = tab
                                }
                            }
                        }
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                    
                    // --- Posts List ---
                    LocalPostListView(
                        posts: getFilteredLocalPosts(posts: postLoader.posts),
                        onRetryUpload: retryUpload,
                        uploadingPosts: uploadingPosts
                    )
                    
                    Spacer()
                }
                .frame(maxHeight: .infinity)
                .padding(.horizontal, 12)
                .padding(.top, 8)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .alert(alertMessage, isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        }
    }
}

// Custom PostListView for AccountPostView that handles local posts and retry uploads
struct LocalPostListView: View {
    let posts: [Post]
    let onRetryUpload: (Post) -> Void
    let uploadingPosts: Set<UUID>
    
    @EnvironmentObject var sessions: SessionLoader
    @EnvironmentObject var curUser: CurUser
    @State private var animationToggle = false
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Spacer()
                .frame(maxWidth: 20)
            if posts.isEmpty {
                Text("No posts yet!")
                    .foregroundColor(.secondary)
            } else {
                ForEach(posts.indices, id: \.self) { index in
                    let post = posts[index]
                    let postInfo = post.toLocalPostInfo(currentUser: curUser, context: viewContext)
                    
                    ZStack {
                        // Original PostItemView
                        PostItemView(postInfo: postInfo)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        // WiFi retry button overlay (positioned in top-right)
                        if post.remoteId == nil {
                            VStack {
                                HStack {
                                    Spacer()
                                    Button(action: { onRetryUpload(post) }) {
                                        if uploadingPosts.contains(post.id) {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: ColorTokens.shade600))
                                                .scaleEffect(0.8)
                                        } else {
                                            Image(systemName: "wifi.slash")
                                                .foregroundColor(ColorTokens.red300)
                                                .font(.system(size: 20, weight: .bold))
                                                .opacity(animationToggle ? 0.3 : 1.0)
                                                .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: animationToggle)
                                        }
                                    }
                                    .disabled(uploadingPosts.contains(post.id))
                                    .padding(.trailing, 30)
                                    .padding(.top, 20)
                                }
                                Spacer()
                            }
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 5)
        .onAppear {
            animationToggle = true
        }
    }
}



#Preview {
    AccountPostView(month: Calendar.current.component(.month, from: Date()),
                   year: Calendar.current.component(.year, from: Date()))
        .environmentObject(PostLoader.loadPostLoader())
        .environmentObject(CredManager(subscriptionManager: SubscriptionManager()))
        .environmentObject(CurUser(credManager: CredManager(subscriptionManager: SubscriptionManager())))
}
