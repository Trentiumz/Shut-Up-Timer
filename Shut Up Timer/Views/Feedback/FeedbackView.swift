import SwiftUI

struct FeedbackView: View {
    @State private var feedbacks: [FeedbackResponse] = FeedbackView.sampleFeedbacks()
    @State private var sortBy: String = "Upvotes"
    
    var avgStars: Double {
        guard !feedbacks.isEmpty else { return 0 }
        let total = feedbacks.reduce(0) { $0 + $1.stars }
        return Double(total) / Double(feedbacks.count)
    }
    
    var body: some View {
        ZStack {
            Background()
            VStack(spacing: 0) {
                // AVG Star Rating
                VStack(spacing: 4) {
                    Text("AVG Star Rating")
                        .font(FontTokens.architectsDaughter(size: 24))
                        .foregroundColor(ColorTokens.shade700)
                    HStack(spacing: 2) {
                        ForEach(1...5, id: \.self) { i in
                            Image(systemName: avgStars >= Double(i) ? "star.fill" : (avgStars >= Double(i) - 0.5 ? "star.lefthalf.fill" : "star"))
                                .resizable()
                                .frame(width: 28, height: 28)
                                .foregroundColor(ColorTokens.red300)
                        }
                    }
                }
                .padding(.vertical, 8)
                .background(alignment: .top) {
                    FormattedImages.LinedImageBackground(width: 320)
                        .rotationEffect(Angle(degrees: 180))
                        .frame(width: 320, height: 90, alignment: .top)
                        .clipped()
                }
                .padding(.bottom, 16)
                
                // Sort & Feedback Buttons
                HStack(spacing: 16) {
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "arrow.up.arrow.down")
                            Text("Sorted by \(sortBy)")
                                .font(FontTokens.architectsDaughter(size: 18))
                                .minimumScaleFactor(0.5)
                                .lineLimit(1)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .foregroundColor(.white)
                        .frame(maxWidth: 180)
                        .background(alignment: .leading) {
                            FormattedImages.FriendCodeStripe(width: 190)
                        }
                    }
                    Button(action: {}) {
                        Text("+ feedback")
                            .font(FontTokens.architectsDaughter(size: 18))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .foregroundColor(ColorTokens.shade100)
                            .background{
                                Rectangle()
                                  .foregroundColor(.clear)
                                  .frame(width: 128, height: 38)
                                  .background(Color(red: 0.51, green: 0.16, blue: 0.17))
                                  .overlay(
                                    Rectangle()
                                      .inset(by: 1)
                                      .stroke(.black, lineWidth: 2)
                                  )
                            }
                    }
                }
                .padding(.bottom, 8)
                
                // Feedback List
                ScrollView {
                    VStack(spacing: 18) {
                        ForEach(feedbacks, id: \.id) { feedback in
                            FeedbackPaperView(feedback: feedback)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.bottom, 60)
                }
            }
        }
    }
    
    // Temporary sample data function
    static func sampleFeedbacks() -> [FeedbackResponse] {
        [
            FeedbackResponse(
                id: UUID(),
                username: "user1",
                pfp: "https://randomuser.me/api/portraits/women/1.jpg",
                stars: 2,
                feedback: "i hate this app lowkey idk why i just dont like it, doesnt vibe with me hehahahahahaah",
                created_at: Date(),
                upvotes: 23
            ),
            FeedbackResponse(
                id: UUID(),
                username: "user1",
                pfp: "https://randomuser.me/api/portraits/women/1.jpg",
                stars: 2,
                feedback: "i hate this app lowkey idk why i just dont like it, doesnt vibe with me hehahahahahaah",
                created_at: Date(),
                upvotes: 23
            ),
            FeedbackResponse(
                id: UUID(),
                username: "user1",
                pfp: "https://randomuser.me/api/portraits/women/1.jpg",
                stars: 2,
                feedback: "i hate this app lowkey idk why i just dont like it, doesnt vibe with me hehahahahahaah",
                created_at: Date(),
                upvotes: 23
            )
        ]
    }
}

struct FeedbackPaperView: View {
    var feedback: FeedbackResponse
    
    var body: some View {
        ZStack(alignment: .top) {
            FormattedImages.LinedImageBackground(width: 340)
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .center, spacing: 8) {
                    AsyncImage(url: URL(string: feedback.pfp)) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Circle().fill(Color.gray)
                    }
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    
                    HStack(spacing: 2) {
                        ForEach(1...5, id: \.self) { i in
                            Image(systemName: feedback.stars >= i ? "star.fill" : "star")
                                .resizable()
                                .frame(width: 18, height: 18)
                                .foregroundColor(ColorTokens.red300)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 0) {
                        Text(feedback.created_at, style: .date)
                            .font(FontTokens.architectsDaughter(size: 14))
                            .foregroundColor(ColorTokens.shade700)
                        Text(feedback.created_at, style: .time)
                            .font(FontTokens.architectsDaughter(size: 14))
                            .foregroundColor(ColorTokens.shade700)
                    }
                }
                .padding(.top, 8)
                
                Text(feedback.feedback)
                    .font(FontTokens.architectsDaughter(size: 18))
                    .foregroundColor(ColorTokens.shade700)
                    .padding(.vertical, 4)
                
                Spacer()
                
                HStack {
                    Spacer()
                    ZStack {
                        FormattedImages.FeedbackUpvoteButton(width: 50)
                        Text("\(feedback.upvotes)")
                            .font(FontTokens.architectsDaughter(size: 20))
                            .foregroundColor(ColorTokens.shade100)
                        // Optionally, add upvote button here
                    }
                    .offset(x: 0, y: 0)
                }
            }
            .padding(.leading, 30)
            .padding(.top, 10)
            .frame(width: 300, height: 200)
        }
    }
}

#Preview {
    FeedbackView()
}
