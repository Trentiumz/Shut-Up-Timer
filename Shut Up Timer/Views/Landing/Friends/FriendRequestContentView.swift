// TODO: Very similar to LBDataView, perhaps we can encapsulate the "chunking paper"?

import SwiftUI

struct FriendRequestContentView: View {
    
    let requests: [FriendRequestResponse]
    let onAccept: (Int) -> Void
    let onDecline: (Int) -> Void

    var body: some View {
        ChunkedPageList(data: requests, chunkSize: 2) { curRequest in
            FriendRequestRowView(entry: curRequest, onAccept: { onAccept(curRequest.id) }, onDecline: { onDecline(curRequest.id) })
        }
    }
}

fileprivate struct FriendRequestRowView: View {
    var entry: FriendRequestResponse
    var onAccept: () -> Void
    var onDecline: () -> Void

    var body: some View {
        HStack(spacing: 20) {
            PFPDisplay(url: entry.pfp, width: 80, height: 80)
            
            VStack(spacing: 0) {
                HStack {
                    Text(entry.username)
                        .font(FontTokens.architectsDaughter(size: 30))
                        .foregroundColor(ColorTokens.shade700)
                    Spacer()
                }
                
                HStack(spacing: 8) {
                    Button(action: {
                        onAccept()
                    }) {
                        ZStack {
                            Rectangle()
                              .foregroundColor(.clear)
                              .frame(width: 85, height: 27)
                              .background(ColorTokens.red300)
                            Text("Accept")
                                .font(FontTokens.architectsDaughter(size: 15))
                                .minimumScaleFactor(0.5)
                                .lineLimit(1)
                                .foregroundColor(ColorTokens.shade100)
                            
                        }
                    }
                    
                    Button(action: {
                        onDecline()
                    }) {
                        ZStack {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 85, height: 27)
                                .overlay(
                                    Rectangle()
                                        .inset(by: 1)
                                        .stroke(ColorTokens.red300, lineWidth: 2)
                                )
                            Text("Decline")
                                .font(FontTokens.architectsDaughter(size: 15))
                                .foregroundColor(ColorTokens.shade700)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: 250)
        .padding(.leading, 40)
    }
}

#Preview {
    FriendRequestContentView(requests: [
        FriendRequestResponse(id: 1, sender_id:UUID(), pfp: "test", username: "test", created_at: Date()),
        FriendRequestResponse(id: 1, sender_id:UUID(), pfp: "test", username: "test", created_at: Date()),
        FriendRequestResponse(id: 1, sender_id:UUID(), pfp: "test", username: "test", created_at: Date()),
        FriendRequestResponse(id: 1, sender_id:UUID(), pfp: "test", username: "test", created_at: Date())
    ], onAccept: {_ in}, onDecline: {_ in})
}
