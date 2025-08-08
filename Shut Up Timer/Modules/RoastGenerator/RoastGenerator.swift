import CoreData
struct RoastGenerator {
    enum RoastType: String, Encodable, Decodable {
        case roast = "roast"
        case catchphrase = "catchphrase"
    }
}
