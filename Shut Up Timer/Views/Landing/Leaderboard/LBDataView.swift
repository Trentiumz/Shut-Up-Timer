import SwiftUI;

struct LBContentView : View {
    var entries: [LBEntry]
    var chunked: [[LBEntry]]
    
    init(entries: [LBEntry]) {
        self.entries = entries;
        self.chunked = stride(from: 0, to: entries.count, by: 3).map { i in
            Array(entries[i..<min(i+3, entries.count)])
        }
    }
    
    var body : some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(Array(chunked.enumerated()), id: \.offset) { ind, triple in
                    LBTripleView(entries: triple, groupInd: ind)
                        .zIndex(1)
                    if ind < chunked.count - 1 {
                        Rectangle()
                            .fill(.clear)
                            .frame(height: 10)
                            .overlay(
                                FormattedImages.LeaderboardBandage(height: 40)
                            )
                            .zIndex(2)
                    }
                }
            }
        }
    }
}

struct LBTripleView : View {
    var entries: [LBEntry]
    var groupInd: Int
    
    var body : some View {
        ZStack(alignment: .top) {
            FormattedImages.LinedImageBackground(width: 350)
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(entries.enumerated()), id: \.offset) { ind, entry in
                    LBRowView(pos: 3 * groupInd + ind + 1, entry: entry)
                    if ind < entries.count - 1 {
                        Rectangle()
                          .foregroundColor(.clear)
                          .frame(width: 280, height: 6)
                          .background(ColorTokens.shade300)
                        Spacer()
                            .frame(maxHeight: 2)
                    }
                }
            }
            .padding(.leading, 50)
            .padding(.top, 15)
            .frame(maxHeight: 220, alignment: .top)
        }
    }
}

struct LBRowView : View {
    var entry: LBEntry;
    var pos: Int
    
    init(pos: Int, entry: LBEntry) {
        self.pos = pos;
        self.entry = entry;
    }
    
    var body: some View {
        HStack {
            Text("\(pos).")
                .font(FontTokens.architectsDaughter(size: 40))
                .multilineTextAlignment(.leading)
                .foregroundColor(ColorTokens.shade700)
                .frame(minWidth: 30)
            Spacer()
                .frame(maxWidth: 20)
            VStack(spacing: 0) {
                AsyncImage(url: URL(string: entry.profilePicture)) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                } placeholder: {
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 40, height: 40)
                }
                Text(entry.name)
                    .font(FontTokens.architectsDaughter(size: 20))
                  .multilineTextAlignment(.center)
                  .foregroundColor(ColorTokens.shade700)
                  .frame(maxWidth: 80, maxHeight: 24)
            }
            Spacer()
                .frame(maxWidth: 30)
            Text("\(entry.pts) IQ")
                .font(FontTokens.architectsDaughter(size: 30))
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.2)
                .foregroundColor(ColorTokens.shade700)
            Spacer()
        }
        .frame(maxWidth: 280)
    }
}

#Preview {
    LBContentView(entries: [LBEntry(name: "Trenasjkdfjdsafjklksdjljklaksfdt", pfp: "halloo", pts: 50), LBEntry(name: "Bob", pfp: "whoops", pts: 20), LBEntry(name: "Bob", pfp: "whoops", pts: 20), LBEntry(name: "Bob", pfp: "whoops", pts: 20), LBEntry(name: "Bob", pfp: "whoops", pts: 20)])
}
