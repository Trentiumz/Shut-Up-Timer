// TODO: Very similar to LBDataView, perhaps we can encapsulate the "chunking paper"?

import SwiftUI

struct SentContentView: View {
    
    let requests: [SentRequestResponse]
    let onWithdraw: (Int) -> Void

    var body: some View {
        ChunkedPageList(data: requests, chunkSize: 2) { curRequest in
            SentRowView(entry: curRequest, onWithdraw: { onWithdraw(curRequest.id) })
        }
        .onAppear {
            print(requests)
        }
    }
}

fileprivate struct SentRowView: View {
    var entry: SentRequestResponse
    var onWithdraw: () -> Void

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
                
                Button(action: {
                    onWithdraw()
                }) {
                    ZStack {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 170, height: 27)
                            .overlay(
                                Rectangle()
                                    .inset(by: 1)
                                    .stroke(ColorTokens.red300, lineWidth: 2)
                            )
                        Text("Withdraw")
                            .font(FontTokens.architectsDaughter(size: 15))
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                            .foregroundColor(ColorTokens.shade700)
                    }
                }
            }
        }
        .frame(maxWidth: 250)
        .padding(.leading, 40)
    }
}

#Preview {
    SentContentView(requests: [
        SentRequestResponse(id: 1, receiver_id:UUID(), pfp: "test", username: "test", created_at: Date()),
        SentRequestResponse(id: 1, receiver_id:UUID(), pfp: "test", username: "test", created_at: Date()),
        SentRequestResponse(id: 1, receiver_id:UUID(), pfp: "test", username: "test", created_at: Date()),
        SentRequestResponse(id: 1, receiver_id:UUID(), pfp: "test", username: "test", created_at: Date())
    ], onWithdraw: {_ in})
}
