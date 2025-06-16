import SwiftUI;

struct ChunkedPageList<Data, RowContent: View>: View {
    let data: [Data]
    let chunkSize: Int
    let rowContent: (Data) -> RowContent
    let itemSpacing: CGFloat
    private var chunks: [[Data]]

    init(
        data: [Data],
        chunkSize: Int = 2,
        itemSpacing: CGFloat = 10,
        @ViewBuilder rowContent: @escaping (Data) -> RowContent
    ) {
        self.data = data
        self.chunkSize = chunkSize
        self.rowContent = rowContent
        self.itemSpacing = itemSpacing
        self.chunks = Utils.chunked(data, size: chunkSize)
    }

    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<chunks.count, id: \.self) { chunkIndex in
                ZStack {
                    FormattedImages.LinedImageBackground(width: 350)
                    VStack(spacing: itemSpacing) {
                        ForEach(Array(chunks[chunkIndex].enumerated()), id: \.offset) { _, item in
                            rowContent(item)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                }
                if chunkIndex < chunks.count - 1 {
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
