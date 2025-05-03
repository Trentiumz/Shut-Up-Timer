import SwiftUI;
struct FriendLeaderboardResponse : Decodable {
    let friend_user_id: UUID
    let friend_username: String
    let friend_iq: Int
}
