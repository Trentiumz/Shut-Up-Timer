import SwiftUI
import Supabase

class FastAPIClient {
    let fastAPIURL: URL
    let supabase: SupabaseClient
    let subscriptionManager: SubscriptionManager
    
    init(supabase: SupabaseClient, subscriptionManager: SubscriptionManager) {
        self.fastAPIURL = URL(string: Config.apiBaseURL)!
        self.supabase = supabase
        self.subscriptionManager = subscriptionManager
    }
    
    func sendAuthenticatedRequest<T: Encodable>(params: T, url: URL, method: String) async throws -> Data {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let token = try await supabase.auth.session.accessToken
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        request.httpBody = try encoder.encode(params)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        if let httpResponse = response as? HTTPURLResponse {
            if 200...299 ~= httpResponse.statusCode {
                return data
            }
        }
        print("API Error: \(response)")
        do {
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw APIError.serverError(description: errorResponse.error)
            }
        }
        throw APIError.serverError(description: "Server Error")
    }
    
    func sendAuthenticatedGetRequest(url: URL) async throws -> Data {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let token = try await supabase.auth.session.accessToken
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        if let httpResponse = response as? HTTPURLResponse {
            if 200...299 ~= httpResponse.statusCode {
                return data
            }
        }
        print("API Error: \(response)")
        do {
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw APIError.serverError(description: errorResponse.error)
            }
        }
        throw APIError.serverError(description: "Server Error")
    }
    
    func sendAuthSubRequest(params: [String: Any], url: URL, method: String) async throws -> Data {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let token = try await supabase.auth.session.accessToken
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        // Add originalTransactionId to params if available
        var requestParams = params
        if let originalTransactionId = await subscriptionManager.originalTransactionId {
            requestParams["originalTransactionId"] = Config.useDebugSubscription ? Config.debugSubscriptionString : "\(originalTransactionId)"
        }
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestParams)
        print(requestParams)
        let (data, response) = try await URLSession.shared.data(for: request)
        if let httpResponse = response as? HTTPURLResponse {
            if 200...299 ~= httpResponse.statusCode {
                return data
            }
        }
        print("API Error: \(response)")
        do {
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw APIError.serverError(description: errorResponse.error)
            }
        }
        throw APIError.serverError(description: "Server Error")
    }
    
    struct AddFeedbackParams: Encodable {
        let stars: Int?
        let feedback: String?
    }
    func addFeedback(_ params: AddFeedbackParams) async -> Bool {
        do {
            _ = try await sendAuthenticatedRequest(params: params, url: fastAPIURL.appendingPathComponent("add-feedback"), method: "POST")
            return true;
        } catch {
            print("Error adding feedback: \(error)")
            return false;
        }
    }
    
    struct SendFriendRequestParams: Encodable {
        let receiver_friend_code: String
    }
    func sendFriendRequest(_ params: SendFriendRequestParams) async throws -> Void {
        _ = try await sendAuthenticatedRequest(params: params, url: fastAPIURL.appendingPathComponent("send-friend-request"), method: "POST")
    }
    
    struct VerifySubscriptionResponse: Codable {
        let is_subscribed: Bool
    }
    
    func verifySubscription() async -> Bool {
        do {
            guard await subscriptionManager.originalTransactionId != nil else {
                return false
            }
            
            let data = try await sendAuthSubRequest(
                params: [:],
                url: fastAPIURL.appendingPathComponent("verify-subscription"),
                method: "POST"
            )
            
            let decoder = JSONDecoder()
            let response = try decoder.decode(VerifySubscriptionResponse.self, from: data)
            return response.is_subscribed
        } catch {
            print("Error verifying subscription: \(error)")
            return false
        }
    }
    
    struct CreatePostParams: Encodable {
        let time: Date
        let duration: Double?
        let top_categories: [String]?
        let iq_change: Double?
        let images: [String]
        let text: String
    }
    
    struct CreatePostResponse: Codable {
        let post_id: String
    }
    
    func createPost(_ postInfo: PostInfo) async -> UUID? {
        var uploadedImageUrls: [String] = []
        var uploadedImageFilepaths: [String] = []
        
        do {
            guard let userID = supabase.auth.currentUser?.id else {
                print("No authenticated user found")
                return nil
            }
            
            let lowerUUID = userID.uuidString.lowercased()
            
            // Upload images to post-images bucket
            for imageInfo in postInfo.images {
                switch imageInfo.type {
                case .local:
                    // Load image from local storage
                    if let image = ImageLoader.loadImage(name: imageInfo.path) {
                        // Resize and compress image
                        let resizedImage = resizeImage(image: image, maxDimension: 1024)
                        guard let data = resizedImage.jpegData(compressionQuality: 0.8) else {
                            print("Failed to convert image to data")
                            continue
                        }
                        
                        // Generate unique filename
                        let fileName = "post_\(UUID().uuidString).jpg"
                        let filePath = "\(lowerUUID)/\(fileName)"
                        
                        // Upload to Supabase storage
                        try await supabase.storage.from("post-images").upload(
                            filePath,
                            data: data,
                            options: FileOptions(
                                cacheControl: "3600",
                                contentType: "image/jpeg"
                            )
                        )
                        
                        // Get public URL
                        let publicURL = try supabase.storage.from("post-images").getPublicURL(path: filePath)
                        uploadedImageUrls.append(publicURL.absoluteString)
                        uploadedImageFilepaths.append(filePath)
                    } else {
                        print("Failed to load local image: \(imageInfo.path)")
                    }
                case .url:
                    // If it's already a URL, use it directly
                    uploadedImageUrls.append(imageInfo.path)
                }
            }
            
            // Create post request
            let createPostParams = CreatePostParams(
                time: postInfo.time,
                duration: postInfo.duration,
                top_categories: postInfo.topCategories,
                iq_change: postInfo.iq_change,
                images: uploadedImageUrls,
                text: postInfo.text
            )
            
            // Send post creation request with proper date formatting
            let data = try await sendAuthenticatedRequest(
                params: createPostParams,
                url: fastAPIURL.appendingPathComponent("create-post"),
                method: "POST"
            )
            
            // Parse the response to get the post_id
            let decoder = JSONDecoder()
            let response = try decoder.decode(CreatePostResponse.self, from: data)
            
            // Convert string UUID to UUID
            guard let postId = UUID(uuidString: response.post_id) else {
                print("Failed to parse post_id UUID: \(response.post_id)")
                return nil
            }
            
            return postId
            
        } catch {
            print("Error creating post: \(error)")
            
            // Clean up uploaded images on failure
            if !uploadedImageFilepaths.isEmpty {
                do {
                    try await supabase.storage.from("post-images").remove(paths: uploadedImageFilepaths)
                    print("Cleaned up uploaded images: \(uploadedImageFilepaths)")
                } catch {
                    print("Failed to cleanup images: \(error)")
                }
            }
            
            return nil
        }
    }
    
    // Helper function to resize images based on minimum dimension and crop center
    private func resizeImage(image: UIImage, maxDimension: CGFloat) -> UIImage {
        let size = image.size
        let minSide = min(size.width, size.height)
        
        var finalImage = image
        var finalWidth = size.width
        var finalHeight = size.height
        
        // Resize if minimum dimension is larger than max
        if minSide > maxDimension {
            let scale = maxDimension / minSide
            finalWidth = size.width * scale
            finalHeight = size.height * scale
            
            UIGraphicsBeginImageContextWithOptions(CGSize(width: finalWidth, height: finalHeight), false, 1.0)
            image.draw(in: CGRect(x: 0, y: 0, width: finalWidth, height: finalHeight))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            guard let resized = resizedImage else { return image }
            finalImage = resized
        }
        
        // Crop center if one dimension is much larger than maxDimension
        let cropSize = maxDimension
        if finalWidth > cropSize || finalHeight > cropSize {
            let cropRect = CGRect(
                x: (finalWidth - cropSize) / 2,
                y: (finalHeight - cropSize) / 2,
                width: cropSize,
                height: cropSize
            )
            
            if let cgImage = finalImage.cgImage?.cropping(to: cropRect) {
                return UIImage(cgImage: cgImage)
            }
        }
        
        return finalImage
    }
    
    struct ServerPost: Codable {
        let id: String
        let user_id: String
        let username: String
        let pfp: String?
        let time: String
        let duration: Double?
        let top_categories: [String]?
        let iq_change: Double?
        let images: [String]
        let created_at: String
        let text: String
    }
    struct GetPostResponse: Codable {
        let posts: [ServerPost]
    }
    
    func getPosts() async -> [PostInfo] {
        do {
            // Send GET request
            let data = try await sendAuthenticatedGetRequest(
                url: fastAPIURL.appendingPathComponent("get-posts")
            )
            
            // Decode server response
            let decoder = JSONDecoder()
            let serverPosts = try decoder.decode(GetPostResponse.self, from: data)
            
            // Convert to PostInfo objects
            let postInfos = serverPosts.posts.compactMap { serverPost -> PostInfo? in
                // Parse id and user_id as UUIDs
                guard let id = UUID(uuidString: serverPost.id),
                      let userId = UUID(uuidString: serverPost.user_id) else {
                    print("Failed to parse UUID from server post: id=\(serverPost.id), user_id=\(serverPost.user_id)")
                    return nil
                }
                
                // Parse time as Date using Utils function
                guard let validTime = parseISO8601Date(serverPost.time) else {
                    print("Failed to parse date from server post: \(serverPost.time)")
                    return nil
                }
                
                // Convert images to PostImageInfo with URL type
                let images = serverPost.images.map { imageUrl in
                    PostImageInfo(type: .url, path: imageUrl)
                }
                
                return PostInfo(
                    id: id,
                    user_id: userId,
                    username: serverPost.username,
                    pfp: serverPost.pfp,
                    time: validTime,
                    duration: serverPost.duration,
                    topCategories: serverPost.top_categories,
                    iq_change: serverPost.iq_change,
                    images: images,
                    text: serverPost.text
                )
            }
            
            return postInfos
            
        } catch {
            print("Error getting posts: \(error)")
            return []
        }
    }
    
    struct GetMyPostResponse : Codable{
        var post_ids: [String]
    }
    func getMyPostIDs() async throws -> [UUID] {
        // Send GET request
        let data = try await sendAuthenticatedGetRequest(
            url: fastAPIURL.appendingPathComponent("get-my-uploaded-post-ids")
        )
        
        // Decode server response
        let decoder = JSONDecoder()
        let uploadedPosts = try decoder.decode(GetMyPostResponse.self, from: data)
        
        // Convert to PostInfo objects
        let postUUIDs = uploadedPosts.post_ids.compactMap { postIdStr in
            UUID(uuidString: postIdStr)
        }
        
        return postUUIDs
    }
}

enum APIError: Error, LocalizedError {
    case networkError
    case decodingError
    case serverError(description: String)
    case invalidURL
    
    var errorDescription: String? {
        switch self {
        case .networkError:
            return "Network connection failed"
        case .decodingError:
            return "Failed to decode response"
        case .serverError(let description):
            return "\(description)"
        case .invalidURL:
            return "Invalid URL"
        }
    }
}

struct ErrorResponse: Codable {
    let error: String
}
