import SwiftUI

struct FriendLeaderboardResponse {
    var userId: String
    var username: String
    var profilePicture: String
    var iq: Int
}

struct FriendProfileResponse {
    var friendUserId: String
    var friendUsername: String
    var friendIq: Int
    var friendProfilePicture: String
}

struct FriendRequestResponse {
    var id: Int64
    var senderId: String
    var receiverId: String
    var createdAt: Date
}

struct FriendsResponse {
    var friendUserId: String
    var createdAt: Date
}

struct FriendsUserIdResponse {
    var friendUserId: String
    var createdAt: Date
}

struct UserProfileResponse {
    var friendCode: String
    var isPublicProfileVisible: Bool
    var sessions: [String: Any] // jsonb, customize decoding as needed
}

struct UserPublicProfileResponse {
    var iq: Int
    var username: String
    var profilePicture: String
    var roasts: [String: Any]
    var hours: TimeInterval
    var lastLogin: Date
    var topCategories: [String: Any]
}

struct WorldLeaderboardResponse {
    var userId: String
    var username: String
    var profilePicture: String
    var iq: Int
}