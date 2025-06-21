import SwiftUI

struct AddFeedbackView: View {
    var curUser: UserPublicProfileResponse
    @State var onAdded: () -> Void
    
    @State var curStars: Int = 0
    @State var curResponse: String = ""
    
    @EnvironmentObject var credManager : CredManager
    
    var body: some View {
        ZStack(alignment: .top) {
            FormattedImages.LinedImageBackground(width: 340)
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .center, spacing: 8) {
                    AsyncImage(url: URL(string: curUser.profile_picture)) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Circle().fill(Color.gray)
                    }
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    
                    HStack(spacing: 2) {
                        ForEach(1...5, id: \.self) { i in
                            Image(systemName: curStars >= i ? "star.fill" : "star")
                                .resizable()
                                .frame(width: 18, height: 18)
                                .foregroundColor(ColorTokens.red300)
                                .onTapGesture {
                                    withAnimation {
                                        curStars = i;
                                    }
                                }
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 0) {
                        Text(Date(), style: .date)
                            .font(FontTokens.architectsDaughter(size: 14))
                            .foregroundColor(ColorTokens.shade700)
                        Text(Date(), style: .time)
                            .font(FontTokens.architectsDaughter(size: 14))
                            .foregroundColor(ColorTokens.shade700)
                    }
                }
                .padding(.top, 8)
                
                TextField("your feedback", text: $curResponse)
                    .lineLimit(5)
                    .minimumScaleFactor(0.7)
                    .font(FontTokens.architectsDaughter(size: 18))
                    .foregroundColor(ColorTokens.shade700)
                    .padding(.vertical, 4)
                
                Spacer()
                HStack {
                    Spacer()
                    Button(action:{
                        Task {
                            let success = await credManager.addFeedback(stars: curStars, feedback: curResponse)
                            if success {
                                await MainActor.run {
                                    withAnimation {
                                        curStars = 0;
                                        curResponse = "";
                                    }
                                    onAdded();
                                }
                            }
                        }
                    }) {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 100, height: 37)
                            .background(Color(red: 0.51, green: 0.16, blue: 0.17))
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .inset(by: 1)
                                    .stroke(.black, lineWidth: 2)
                            )
                            .overlay(
                                Text("Submit")
                                    .font(FontTokens.architectsDaughter(size: 20))
                                    .foregroundColor(ColorTokens.shade100)
                            )
                    }
                    FormattedImages.FeedbackUpvoteButton(height: 52)
                }
            }
            .padding(.leading, 30)
            .padding(.top, 10)
            .frame(width: 300, height: 210)
        }
    }
}

#Preview {
    AddFeedbackView(curUser: UserPublicProfileResponse(iq: 0, username: "tester", profile_picture: "alkdsfj", roasts: [], hours: "", top_categories: []), onAdded: {})
}
