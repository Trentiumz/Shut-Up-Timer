//
//  Post.swift
//  Shut Up Timer
//
//  Created by Daniel Ye on 2025-07-02.
//

import Foundation
import SwiftUI
import Combine
import CoreData

// Represents a single image associated with a post
struct PostImage: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var imageName: String // The filename used in ImageLoader
}

// Represents a post tied to a session
struct Post: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var remoteId: UUID? = nil
    var sessionID: UUID?
    var text: String
    var images: [PostImage]
    var createdAt: Date
    
    func toLocalPostInfo(currentUser: CurUser, context: NSManagedObjectContext) -> PostInfo {
        // Find the session associated with this post using Core Data
        var session: Session? = nil
        if let sessionID = sessionID {
            let sessionRequest: NSFetchRequest<Session> = Session.fetchRequest()
            sessionRequest.predicate = NSPredicate(format: "id == %@", sessionID as CVarArg)
            session = try? context.fetch(sessionRequest).first
        }
        
        // Extract session data or use defaults
        let sessionTime = session?.started
        let time = session?.timeLocked ?? 0
        let iqChange = session?.iqChange ?? 0
        
        // Get top categories as strings for the specific session using Core Data
        let topCategories: [String]
        if let session = session {
            let taskLogs = session.taskLogsArray.prefix(3) // Get top 3 categories
            topCategories = taskLogs.compactMap { taskLog in
                taskLog.todo?.todo
            }
        } else {
            topCategories = []
        }
        
        // Convert PostImage to PostImageInfo
        let postImages = self.images.map { postImage in
            PostImageInfo(type: .local, path: postImage.imageName)
        }
        
        return PostInfo(
            id: self.id,
            user_id: currentUser.credManager.getUserId() ?? UUID(),
            username: currentUser.userPublicProfile?.username ?? "Unknown",
            pfp: currentUser.userPublicProfile?.profile_picture,
            time: sessionTime ?? Date(),
            duration: time,
            topCategories: topCategories,
            iq_change: iqChange,
            images: postImages,
            text: self.text
        )
    }
}

// Loader for all posts. Only allows controlled insert/delete, never arbitrary save.
class PostLoader: ObservableObject {
    @Published private(set) var posts: [Post] = [] {
        didSet {
            savePosts()
            didChange.send(self)
        }
    }
    let didChange = PassthroughSubject<PostLoader, Never>()
    private static var postLoaderInstance: PostLoader? = nil
    
    // MARK: - Codable
    private init(posts: [Post] = []) {
        self.posts = posts
    }
    
    // Loads posts from UserDefaults
    static func loadPostLoader() -> PostLoader {
        if let loaderInstance = postLoaderInstance {
            return loaderInstance
        } else {
            let data = UserDefaults.standard.data(forKey: "user-posts")
            if let liveData = data {
                if let decoded = try? JSONDecoder().decode([Post].self, from: liveData) {
                    let instance = PostLoader(posts: decoded)
                    print(instance.posts)
                    postLoaderInstance = instance
                    return instance
                } else {
                    print("Incorrect Data Type for PostLoader")
                    let instance = PostLoader()
                    postLoaderInstance = instance
                    instance.savePosts()
                    return instance
                }
            } else {
                let instance = PostLoader()
                instance.savePosts()
                postLoaderInstance = instance
                return instance
            }
        }
    }
    
    // Inserts a new post, saving images to disk
    func insertPost(sessionID: UUID?, text: String, images: [UIImage]) -> Post {
        var postImages: [PostImage] = []
        for image in images {
            let imageName = "post_\(UUID().uuidString)"
            let success = ImageLoader.saveImage(name: imageName, image: image)
            if success {
                postImages.append(PostImage(imageName: imageName))
            } else {
                print("Failed to save image for post")
            }
        }
        let post = Post(sessionID: sessionID, text: text, images: postImages, createdAt: Date())
        posts.append(post)
        return post
    }
    
    // Deletes a post and its associated images by UUID
    func deletePost(_ postID: UUID) {
        guard let idx = posts.firstIndex(where: { $0.id == postID }) else { return }
        let post = posts[idx]
        for postImage in post.images {
            _ = ImageLoader.deleteImage(name: postImage.imageName)
        }
        posts.remove(at: idx)
    }
    
    // Updates the remoteId of a post by UUID
    func updateRemoteId(_ postID: UUID, remoteId: UUID) {
        for i in 0..<posts.count {
            if posts[i].id == postID {
                posts[i].remoteId = remoteId
                break
            }
        }
    }
    
    // Private: Save posts to UserDefaults
    private func savePosts() {
        if let encoded = try? JSONEncoder().encode(self.posts) {
            UserDefaults.standard.set(encoded, forKey: "user-posts")
        }
    }
}

