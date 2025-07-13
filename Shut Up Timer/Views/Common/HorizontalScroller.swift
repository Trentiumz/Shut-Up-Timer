import SwiftUI;

// --- Generalized Horizontal Scroller ---
struct HorizontalScroller<Data, Content: View>: View {
    let data: [Data]
    let itemWidth: CGFloat
    let spacing: CGFloat
    let content: (Data) -> Content
    let numItems: Int
    let containerWidth: CGFloat

    @State private var scrollIndex: Int = 0

    init(data: [Data], itemWidth: CGFloat, numItems: Int, spacing: CGFloat = 16, @ViewBuilder content: @escaping (Data) -> Content) {
        self.data = data
        self.itemWidth = itemWidth
        self.spacing = spacing
        self.content = content
        self.numItems = numItems
        self.containerWidth = itemWidth * CGFloat(numItems) + spacing * CGFloat(numItems - 1)
    }

    var body: some View {
        HStack(spacing: 0) {
            Button(action: {
                withAnimation { scrollIndex = max(0, scrollIndex - 1) }
            }) {
                FormattedImages.DisappointmentChevron(height: 80)
                    .rotationEffect(Angle(degrees: 180))
                    .opacity(scrollIndex > 0 ? 1 : 0.3)
            }
            .frame(width: 40)
            Spacer()
                .frame(maxWidth: 20)

            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: spacing) {
                        ForEach(Array(data.enumerated()), id: \.offset) { idx, item in
                            content(item)
                                .frame(width: itemWidth)
                                .id(idx)
                        }
                    }
                }
                .frame(width: containerWidth)
                .onChange(of: scrollIndex) { idx in
                    withAnimation {
                        proxy.scrollTo(idx, anchor: .leading)
                    }
                }
            }

            Spacer()
                .frame(maxWidth: 20)
            Button(action: {
                withAnimation { scrollIndex = min(data.count - numItems, scrollIndex + 1) }
            }) {
                FormattedImages.DisappointmentChevron(height: 80)
                    .opacity(scrollIndex < data.count - numItems ? 1 : 0.3)
            }
            .frame(width: 40)
        }
    }
}

#Preview {
    HorizontalScroller(data: ["Hello", "bye", "Hello There", "Hello There", "Hello There", "Hello There"], itemWidth: 100, numItems: 2) { data in
        Text(data)
            .frame(width: 100, height: 50)
            .background(.red)
    }
}
