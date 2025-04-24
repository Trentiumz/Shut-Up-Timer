import SwiftUI

// a generic slider
struct Slider: View {
    @State private var dragOffset: CGFloat = 0
    @State private var sliderWidth: CGFloat = 0
    private var onActivate: () -> Void;
    private var message: String;
    
    init(onActivate: @escaping () -> Void, message: String) {
        self.onActivate = onActivate;
        self.message = message;
    }

    var body: some View {
        HStack {
            // Slider Handle
            Circle()
                .fill(Color.blue)
                .frame(width: 70, height: 70)
                .offset(x: dragOffset)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            let newOffset = max(0, min(gesture.translation.width, sliderWidth - 70))
                            dragOffset = newOffset
                        }
                        .onEnded { _ in
                            if dragOffset > sliderWidth - 100 {
                                withAnimation {
                                    dragOffset = sliderWidth - 70
                                    onActivate()
                                }
                            } else {
                                withAnimation {
                                    dragOffset = 0
                                }
                            }
                        }
                )
            Spacer()
        }
        .frame(height: 80)
        .background(
            // slider back
            RoundedRectangle(cornerRadius: 40)
                .fill(Color.gray)
                .overlay(
                    GeometryReader { geo in
                        Color.clear
                            .onAppear {
                                sliderWidth = geo.size.width
                            }
                    }
                )
        )
        .overlay(
            // the message
            Text(message)
                .foregroundColor(.white)
                .font(.headline)
        )
        .padding()
    }
}

#Preview {
    Slider(onActivate: {
        print("Triggered")
    }, message: "Do you really want to give up?")
}
