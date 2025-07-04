//
//  PostListView.swift
//  Shut Up Timer
//
//  Created by Daniel Ye on 2025-07-03.
//

import SwiftUI

struct PostListView: View {
    let posts: [PostInfo]
    @EnvironmentObject var postLoader: PostLoader
    @EnvironmentObject var sessions: Sessions
    @Environment(ToDoListV2.self) var todoList
    
    var body: some View {
        ZStack {
            Background()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Spacer()
                        .frame(maxWidth: 20)
                    if posts.isEmpty {
                        Text("No posts yet!")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(posts.indices, id: \.self) { index in
                            PostItemView(postInfo: posts[index])
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 5)
            }
        }
    }
}

struct PostItemView: View {
    let postInfo: PostInfo
    @EnvironmentObject var postLoader: PostLoader
    
    var body: some View {
        VStack(spacing: 10) {
            // User info section (similar to UserInfoView)
            PostUserInfoView(postInfo: postInfo)
                .frame(maxWidth: .infinity, alignment: .center)
            
            // Post images section
            PostImagesView(postInfo: postInfo)
                .frame(maxWidth: .infinity)
        }
    }
}

struct PostUserInfoView: View {
    let postInfo: PostInfo
    
    private var timeAgoString: String {
        guard let sessionTime = postInfo.session_time else { return "Unknown time" }
        let now = Date()
        let interval = now.timeIntervalSince(sessionTime)
        
        if interval < 60 {
            return "Just now"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes)min ago"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours)hrs ago"
        } else {
            let days = Int(interval / 86400)
            return "\(days)d ago"
        }
    }
    
    private var hoursString: String {
        let hours = postInfo.time / 3600
        return String(format: "%.1fhrs", hours)
    }
    
    private var studiesString: String {
        return postInfo.topCategories.first ?? "Unknown"
    }
    
    private var iqChangeString: String {
        if postInfo.iq_change >= 0 {
            return String(format: "+%.2f", postInfo.iq_change)
        } else {
            return String(format: "%.2f", postInfo.iq_change)
        }
    }
    
    var body: some View {
        ZStack {
            FormattedImages.UserInfoBackground(width: 340, height: 190)
            VStack(spacing: 10) {
                // Profile Picture and Username
                HStack(spacing: 30) {
                    // Profile Picture
                    PFPDisplay(url: postInfo.pfp ?? "", width: 80, height: 80)
                    
                    VStack {
                        // Username
                        Text(postInfo.username)
                            .font(FontTokens.architectsDaughter(size: 30))
                            .foregroundColor(ColorTokens.shade700)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity)
                            .minimumScaleFactor(0.01)
                        
                        // Time and location
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(ColorTokens.shade600)
                            Text(timeAgoString + " • Home")
                                .font(FontTokens.architectsDaughter(size: 16))
                                .foregroundColor(ColorTokens.shade600)
                        }
                    }
                    Spacer()
                }
                
                // Stats
                HStack(spacing: 20) {
                    // Hours
                    VStack {
                        Text("Hours")
                            .font(FontTokens.architectsDaughter(size: 20))
                            .foregroundColor(ColorTokens.shade600)
                        Text(hoursString)
                            .font(FontTokens.architectsDaughter(size: 20))
                            .foregroundColor(ColorTokens.shade700)
                        Spacer()
                    }
                    .frame(height: 70)
                    
                    // Studies
                    VStack {
                        Text("Studies")
                            .font(FontTokens.architectsDaughter(size: 20))
                            .foregroundColor(ColorTokens.shade600)
                        Text(studiesString)
                            .font(FontTokens.architectsDaughter(size: 20))
                            .foregroundColor(ColorTokens.shade700)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                        Spacer()
                    }
                    .frame(height: 70)
                    
                    // IQ change
                    VStack {
                        Text("IQ+/-")
                            .font(FontTokens.architectsDaughter(size: 20))
                            .foregroundColor(ColorTokens.shade600)
                        Text(iqChangeString)
                            .font(FontTokens.architectsDaughter(size: 20))
                            .foregroundColor(postInfo.iq_change >= 0 ? .green : .red)
                        Spacer()
                    }
                    .frame(height: 70)
                    
                    Spacer()
                }
            }
            .padding(.leading, 20)
            .cornerRadius(15)
            .frame(width: 320, height: 190)
        }
    }
}

struct PostImagesView: View {
    let postInfo: PostInfo
    @EnvironmentObject var postLoader: PostLoader
    
    var body: some View {
        if !postInfo.images.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 18) {
                    ForEach(Array(postInfo.images.enumerated()), id: \.offset) { _, imageInfo in
                        PostImageViewForInfo(imageInfo: imageInfo)
                            
                    }
                }
            }
            .padding(.horizontal, 30)
            .frame(height: 170)
        }
    }
}

struct PostImageViewForInfo: View {
    let imageInfo: PostImageInfo
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                // Add space for the bandage to render above
                Spacer().frame(height: 15)
                Group {
                    switch imageInfo.type {
                    case .local:
                        if let image = ImageLoader.loadImage(name: imageInfo.path) {
                            PostImageDisplay(image: image)
                        } else {
                            FormattedImages.PolaroidBG(innerContent: {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .overlay(
                                        Image(systemName: "photo")
                                            .foregroundColor(.gray)
                                    )
                            }, height: 141)
                        }
                    case .url:
                        FormattedImages.PolaroidBG(innerContent: {
                            AsyncImage(url: URL(string: imageInfo.path)) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                            } placeholder: {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .overlay(
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle())
                                    )
                            }
                        }, height: 141)
                    }
                }
            }
            // Bandage above the image
            FormattedImages.LeaderboardBandage(width: 80)
        }
    }
}

#Preview {
    let dummyPosts = [
        PostInfo(
            id: UUID(),
            user_id: UUID(),
            username: "Kailey Cheng",
            pfp: "",
            session_time: Date().addingTimeInterval(-300), // 5 minutes ago
            time: 8820, // 2.45 hours in seconds
            topCategories: ["ECO101"],
            iq_change: 0.12,
            images: [
                PostImageInfo(type: .local, path: "mock_image_1"),
                PostImageInfo(type: .url, path: "https://via.placeholder.com/300x300/FFB6C1/000000?text=Study+Session")
            ]
        ),
        PostInfo(
            id: UUID(),
            user_id: UUID(),
            username: "Daniel Ye",
            pfp: "",
            session_time: Date().addingTimeInterval(-18000), // 5 hours ago
            time: 18720, // 5.2 hours in seconds
            topCategories: ["CSC148"],
            iq_change: -0.053,
            images: [
                PostImageInfo(type: .url, path: "https://via.placeholder.com/300x300/87CEEB/000000?text=Failed+Session"),
                PostImageInfo(type: .local, path: "mock_image_2"),
                PostImageInfo(type: .url, path: "https://via.placeholder.com/300x300/90EE90/000000?text=Roast+Image")
            ]
        )
    ]
    
    PostListView(posts: dummyPosts)
        .environmentObject(PostLoader.loadPostLoader())
        .environmentObject(SessionsLoader.loadSessions(onUpdate: { _ in }))
        .environment(ToDoLoader.getToDo())
}

