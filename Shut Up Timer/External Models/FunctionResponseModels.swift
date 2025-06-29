import SwiftUI

struct FriendLeaderboardResponse : Codable{
    var user_id: UUID
    var username: String
    var profile_picture: String
    var iq: Int
}

struct FriendProfileResponse : Codable{
    var friend_user_id: UUID
    var friend_username: String
    var friend_iq: Int
    var friend_profile_picture: String
}

struct FriendRequestResponse : Codable{
    var id: Int
    var sender_id: UUID
    var pfp: String
    var username: String
    var created_at: Date
}

struct SentRequestResponse : Codable{
    var id: Int
    var receiver_id: UUID
    var pfp: String
    var username: String
    var created_at: Date
}

struct FriendsResponse : Codable{
    var friend_user_id: UUID
    var created_at: Date
}

struct FriendsUserIdResponse : Codable{
    var friend_user_id: UUID
    var created_at: Date
}

struct UserProfileResponse : Codable{
    var friend_code: String
    var is_public_profile_visible: Bool
    var sessions: [String]
}

struct UserPublicProfileResponse : Codable{
    var iq: Int
    var username: String
    var profile_picture: String
    var roasts: [String]
    var hours: String
    var last_login: Date?
    var top_categories: [String]
}

struct WorldLeaderboardResponse : Codable{
    var user_id: UUID
    var username: String
    var profile_picture: String
    var iq: Int
}

struct FeedbackResponse : Codable {
    var id: UUID
    var user_id: UUID
    var username: String?
    var pfp: String?
    var stars: Int?
    var feedback: String?
    var developer_response: String?
    var created_at: Date
    var upvotes: Int
    var user_upvoted: Bool
}
