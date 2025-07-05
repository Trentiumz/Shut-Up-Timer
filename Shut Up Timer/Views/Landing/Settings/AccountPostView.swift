import SwiftUI

struct AccountPostView: View {
    @EnvironmentObject var sessions: Sessions
    @EnvironmentObject var postLoader: PostLoader
    @Environment(CurUser.self) var curUser
    @Environment(ToDoListV2.self) var todoList
    @State private var selectedTab: PostTab = .month
    
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

    // Get posts for current month
    func getMonthPosts(posts: [Post]) -> [PostInfo] {
        // Convert all posts to PostInfo objects
        let allPostInfos = posts.map { post in
            post.toLocalPostInfo(sessions: sessions, currentUser: curUser, todoList: todoList)
        }
        
        // Filter for current month
        let monthPosts = allPostInfos.filter { postInfo in
            let postMonth = Calendar.current.component(.month, from: postInfo.time)
            let postYear = Calendar.current.component(.year, from: postInfo.time)
            return postMonth == month && postYear == year
        }
        
        // Sort by most recent first
        return monthPosts.sorted { 
            return $0.time > $1.time
        }
    }

    // Get all posts
    func getAllPosts(posts: [Post]) -> [PostInfo] {
        // Convert all posts to PostInfo objects
        let allPostInfos = posts.map { post in
            post.toLocalPostInfo(sessions: sessions, currentUser: curUser, todoList: todoList)
        }
        
        // Sort by most recent first
        return allPostInfos.sorted {
            return $0.time > $1.time
        }
    }

    // Get filtered posts based on selected tab
    func getFilteredPosts(posts: [Post]) -> [PostInfo] {
        return selectedTab == .month ? getMonthPosts(posts: posts) : getAllPosts(posts: posts)
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
                    PostListView(posts: getFilteredPosts(posts: postLoader.posts))
                    
                    Spacer()
                }
                .frame(maxHeight: .infinity)
                .padding(.horizontal, 12)
                .padding(.top, 8)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    AccountPostView(month: Calendar.current.component(.month, from: Date()),
                   year: Calendar.current.component(.year, from: Date()))
        .environmentObject(Sessions(sessions: [], onUpdate: {_ in }))
        .environmentObject(PostLoader.loadPostLoader())
        .environment(ToDoLoader.getToDo())
        .environment(CurUser(credManager: CredManager()))
}
