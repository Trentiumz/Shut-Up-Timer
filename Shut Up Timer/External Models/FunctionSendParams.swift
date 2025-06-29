import SwiftUI;

struct AddFeedbackParams: Codable {
    let stars: Int?
    let feedback: String?
    
    init(stars: Int?, feedback: String?) {
        self.stars = stars;
        self.feedback = feedback;
    }
}
