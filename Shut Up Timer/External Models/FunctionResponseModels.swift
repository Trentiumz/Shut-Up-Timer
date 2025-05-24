import SwiftUI

struct FriendLeaderboardResponse {
    var user_id: String
    var username: String
    var profile_picture: String
    var iq: Int
}

struct FriendProfileResponse {
    var friend_user_id: String
    var friend_username: String
    var friend_iq: Int
    var friend_profile_picture: String
}

struct FriendRequestResponse {
    var id: Int64
    var sender_id: String
    var receiver_id: String
    var created_at: Date
}

struct FriendsResponse {
    var friend_user_id: String
    var created_at: Date
}

struct FriendsUserIdResponse {
    var friend_user_id: String
    var created_at: Date
}

struct UserProfileResponse {
    var friend_code: String
    var is_public_profile_visible: Bool
    var sessions: [String: Any] // jsonb, customize decoding as needed
}

struct UserPublicProfileResponse {
    var iq: Int
    var username: String
    var profile_picture: String
    var roasts: [String: Any]
    var hours: TimeInterval
    var last_login: Date
    var top_categories: [String: Any]
}

struct WorldLeaderboardResponse {
    var user_id: String
    var username: String
    var profile_picture: String
    var iq: Int
}