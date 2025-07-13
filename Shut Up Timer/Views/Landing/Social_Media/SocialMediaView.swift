import SwiftUI

struct SocialMediaView: View {
    @EnvironmentObject var credManager: CredManager
    @EnvironmentObject var postLoader: PostLoader
    @EnvironmentObject var sessions: Sessions
    @EnvironmentObject var todoList: ToDoListV2
    
    @State private var posts: [PostInfo] = []
    @State private var isLoading = false

    var body: some View {
        ZStack {
            Background()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            ScrollView {
                VStack(spacing: 16) {
                    if isLoading {
                        ProgressView("Loading posts...")
                            .padding()
                    } else {
                        PostListView(posts: posts)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 5)
            }
        }
        .onAppear {
            Task {
                await fetchPosts()
            }
        }
        .refreshable {
            Task {
                await fetchPosts()
            }
        }
    }
    
    private func fetchPosts() async {
        isLoading = true
        let fetchedPosts = await credManager.fastAPI.getPosts()
        await MainActor.run {
            posts = fetchedPosts
            isLoading = false
        }
    }
}

#Preview {
    SocialMediaView()
        .environmentObject(CredManager())
        .environmentObject(PostLoader.loadPostLoader())
        .environmentObject(SessionsLoader.loadSessions())
        .environmentObject(ToDoLoader.getToDo())
}
