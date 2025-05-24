import SwiftUI

struct FriendLeaderboardResponse : Codable{
    var user_id: String
    var username: String
    var profile_picture: String
    var iq: Int
}

struct FriendProfileResponse : Codable{
    var friend_user_id: String
    var friend_username: String
    var friend_iq: Int
    var friend_profile_picture: String
}

struct FriendRequestResponse : Codable{
    var id: Int64
    var sender_id: String
    var receiver_id: String
    var created_at: Date
}

struct FriendsResponse : Codable{
    var friend_user_id: String
    var created_at: Date
}

struct FriendsUserIdResponse : Codable{
    var friend_user_id: String
    var created_at: Date
}

struct UserProfileResponse : Codable{
    var friend_code: String
    var is_public_profile_visible: Bool
    var sessions: [String: Any] // jsonb, customize decoding as needed
}

struct UserPublicProfileResponse : Codable{
    var iq: Int
    var username: String
    var profile_picture: String
    var roasts: [String: Any]
    var hours: TimeInterval
    var last_login: Date
    var top_categories: [String: Any]
}

struct WorldLeaderboardResponse : Codable{
    var user_id: String
    var username: String
    var profile_picture: String
    var iq: Int
}