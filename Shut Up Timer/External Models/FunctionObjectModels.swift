import Foundation

struct PostImageInfo: Codable {
    let type: ImageType
    let path: String
    
    enum ImageType: String, Codable {
        case local
        case url
    }
}

struct PostInfo : Codable {
    var id: UUID
    var user_id: UUID
    var username: String
    var pfp: String?
    var session_time: Date?
    var time: TimeInterval
    var topCategories: [String]
    var iq_change: Double
    var images: [PostImageInfo]
}
