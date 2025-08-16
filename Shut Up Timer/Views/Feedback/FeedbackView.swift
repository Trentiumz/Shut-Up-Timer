import SwiftUI

struct FeedbackView: View {
    @State private var feedbacks: [FeedbackResponse] = []
    @State private var sortBy: FeedbackCategories = .upvotes
    
    @State private var addFeedbackShowing: Bool = false
    @EnvironmentObject var credManager : CredManager
    @EnvironmentObject var curUser: CurUser
    
    enum FeedbackCategories : String, CaseIterable {
        case upvotes = "Upvotes"
        case recent = "Recent"
        case my = "My"
    }
    
    var avgStars: Double {
        guard !feedbacks.isEmpty else { return 0 }
        let feedbacksWithStars: [Int] = feedbacks.compactMap { $0.stars }
        let total = feedbacksWithStars.reduce(0, +)
        return feedbacksWithStars.isEmpty ? 0 : Double(total) / Double(feedbacksWithStars.count)
    }
    
    func updateFeedbacks() {
        Task {
            let feedbacks = switch(sortBy) {
            case .upvotes:
                await credManager.getFeedbackByUpvotes()
            case .recent:
                await credManager.getFeedbackByRecent()
            case .my:
                await credManager.getMyFeedback()
            }
            await MainActor.run {
                withAnimation {
                    self.feedbacks = feedbacks;
                }
            }
        }
    }
    
    func upvoteFeedback(feedbackID: UUID) {
        Task {
            let success = await credManager.upvoteFeedback(feedbackID: feedbackID)
            if success {
                updateFeedbacks()
            }
        }
    }
    
    func removeFeedback(feedbackID: UUID) {
        Task {
            let success = await credManager.removeFeedback(feedbackID: feedbackID)
            if success {
                updateFeedbacks()
            }
        }
    }
    
    func removeUpvote(feedbackID: UUID) {
        Task {
            let success = await credManager.removeUpvote(feedbackID: feedbackID)
            if success {
                updateFeedbacks()
            }
        }
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Background()
            if let curPP = curUser.userPublicProfile {
                VStack(spacing: 0) {
                    
                    // TODO: stars removed
                    /*
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
                    .padding(.top, 6)
                    .background(alignment: .top) {
                        FormattedImages.LinedImageBackground(width: 320)
                            .rotationEffect(Angle(degrees: -178.45))
                            .frame(width: 320, height: 90, alignment: .top)
                            .offset(y: 4)
                            .clipped()
                    }
                     */
                    
                    Spacer()
                        .frame(maxHeight: 36)
                    
                    // Sort & Feedback Buttons
                    HStack(spacing: 16) {
                        Menu {
                            ForEach(FeedbackCategories.allCases, id: \.rawValue) { cat in
                                Button(action: {
                                    sortBy = cat;
                                    updateFeedbacks()
                                }) {
                                    Text(cat.rawValue)
                                }
                                .tag(cat)
                            }
                        } label: {
                            HStack {
                                Image(systemName: "arrow.up.arrow.down")
                                Text("Sorted by")
                                    .font(FontTokens.architectsDaughter(size: 18))
                                    .minimumScaleFactor(0.5)
                                    .lineLimit(1)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .foregroundColor(.white)
                            .frame(maxWidth: 180)
                            .background(alignment: .leading) {
                                FormattedImages.FriendCodeStripe(width: 180)
                            }
                        }
                        Button(action: {
                            addFeedbackShowing = !addFeedbackShowing
                        }) {
                            Text(addFeedbackShowing ? "- feedback" : "+ feedback")
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
                    
                    if addFeedbackShowing {
                        AddFeedbackView(curUser: curPP, onAdded: {
                            withAnimation {
                                addFeedbackShowing = false
                            }
                            updateFeedbacks()
                        })
                    }
                    
                    // Feedback List
                    ScrollView {
                        VStack(spacing: 32) {
                            Spacer()
                                .frame(height: 36)
                            ForEach(feedbacks, id: \.id) { feedback in
                                FeedbackPaperView(
                                    feedback: feedback,
                                    onUpvote: {upvoteFeedback(feedbackID: feedback.id)},
                                    onRemoveUpvote: { removeUpvote(feedbackID: feedback.id)},
                                    deleteFeedback: {
                                        removeFeedback(feedbackID: feedback.id)
                                })
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.bottom, 60)
                    }
                }
            } else {
                VStack(spacing: 4) {
                    Text("Log in to view feedback")
                        .font(FontTokens.architectsDaughter(size: 22))
                        .foregroundColor(ColorTokens.shade700)
                }
                .padding(.top, 16)
                .background(alignment: .top) {
                    FormattedImages.LinedImageBackground(width: 320)
                        .rotationEffect(Angle(degrees: -178.45))
                        .frame(width: 320, height: 90, alignment: .top)
                        .offset(y: 4)
                        .clipped()
                        .offset(x: 10)
                }
            }
        }
        .onAppear{
            curUser.refresh()
            updateFeedbacks()
        }
        .onChange(of: credManager.loggedIn) { _ in
            curUser.refresh()
        }
    }
}

struct FeedbackPaperView: View {
    var feedback: FeedbackResponse
    var onUpvote: () -> Void
    var onRemoveUpvote: () -> Void
    
    @EnvironmentObject var credManager: CredManager;
    
    @State var showRemovalAlert: Bool = false;
    var deleteFeedback: () -> Void
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            ZStack(alignment: .top) {
                FormattedImages.LinedImageBackground(width: 340)
                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .center, spacing: 8) {
                        PFPDisplay(url: feedback.pfp ?? "", width: 40, height: 40)
                        
                        if let stars = feedback.stars {
                            HStack(spacing: 2) {
                                ForEach(1...5, id: \.self) { i in
                                    Image(systemName: stars >= i ? "star.fill" : "star")
                                        .resizable()
                                        .frame(width: 18, height: 18)
                                        .foregroundColor(ColorTokens.red300)
                                }
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
                    
                    Text(feedback.feedback ?? "")
                        .font(FontTokens.architectsDaughter(size: 18))
                        .foregroundColor(ColorTokens.shade700)
                        .padding(.vertical, 4)
                    
                    Spacer()
                    
                    HStack(alignment: .bottom) {
                        if feedback.user_id == credManager.getUserId() {
                            Button(action: {
                                showRemovalAlert = true
                            }) {
                                Image(systemName: "trash.circle")
                                    .resizable()
                                    .frame(width: 32, height: 32)
                                    .foregroundStyle(ColorTokens.red100)
                            }
                        }
                        Spacer()
                        ZStack {
                            if feedback.user_upvoted {
                                Button(action: {
                                    onRemoveUpvote()
                                }) {
                                    FormattedImages.FeedbackUpvoteButton(width: 50)
                                }
                            } else {
                                Button (action: {
                                    onUpvote()
                                }) {
                                    FormattedImages.FeedbackUpvoteButton(width: 50)
                                        .opacity(0.5)
                                }
                            }
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
            .overlay(alignment: .top) {
                FormattedImages.LeaderboardBandage(width: 150)
                    .offset(y: -26)
            }
            if let developerResponse = feedback.developer_response {
                ZStack(alignment: .trailing) {
                    ZStack(alignment: .leading) {
                        FormattedImages.DisappointmentStrip(width: 300);
                        FormattedImages.LeaderboardBandage(width: 70)
                            .rotationEffect(Angle(degrees: 90))
                            .offset(x: -30)
                    }
                    Text("Developer Response: \(developerResponse)")
                        .font(FontTokens.architectsDaughter(size: 20))
                        .minimumScaleFactor(0.5)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                        .frame(width: 260, height: 50, alignment: .leading)
                        .foregroundColor(ColorTokens.shade700)
                }
                .frame(height: 30, alignment: .bottom)
            }
        }
        .alert("Delete this feedback?", isPresented: $showRemovalAlert) {
            Button("Delete", role: .destructive) {
                deleteFeedback();
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}

#Preview {
    FeedbackPaperView(feedback: FeedbackResponse(id: UUID(), user_id: UUID(), feedback: "Hello there!", developer_response: "Hello back!", created_at: Date(), upvotes: 23, user_upvoted: false), onUpvote: {}, onRemoveUpvote: {}, deleteFeedback: {})
        .environmentObject(CredManager(subscriptionManager: SubscriptionManager()))
//    FeedbackView()
//        .environmentObject(CredManager(subscriptionManager: SubscriptionManager()))
}
