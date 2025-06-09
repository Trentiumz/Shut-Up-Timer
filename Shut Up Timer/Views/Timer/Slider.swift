import SwiftUI

// a generic slider
struct Slider: View {
    @State private var dragOffset: CGFloat = 0
    @State private var sliderWidth: CGFloat = 284
    private var onActivate: () -> Void;
    private var message: String;
    
    init(onActivate: @escaping () -> Void, message: String) {
        self.onActivate = onActivate;
        self.message = message;
    }

    var body: some View {
        HStack {
            // Slider Handle
            Rectangle()
              .foregroundColor(.clear)
              .frame(width: 70, height: 70)
              .background(
                ImageAssets.timerSliderLogo
                  .resizable()
                  .aspectRatio(contentMode: .fill)
                  .frame(width: 70, height: 70)
                  .clipped()
              )
              .cornerRadius(10)
              .overlay(
                RoundedRectangle(cornerRadius: 10)
                  .inset(by: 1)
                  .stroke(ColorTokens.shade700, lineWidth: 2)
              )
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
        .frame(width: sliderWidth, height: 80)
        .background(
            // the message
            HStack {
                Spacer()
                Text(message)
                  .font(Font.custom("Architects Daughter", size: 20))
                  .foregroundColor(ColorTokens.shade700)
                  .frame(width: 148, height: 33, alignment: .topLeading)
                Spacer()
                    .frame(maxWidth: 30)
            }
        )
        .background(
            // slider back
            Rectangle()
              .foregroundColor(.clear)
              .frame(width: sliderWidth, height: 70)
              .background(ColorTokens.shade300)
              .cornerRadius(10)
              .overlay(
                RoundedRectangle(cornerRadius: 10)
                  .inset(by: 1)
                  .stroke(ColorTokens.shade700, lineWidth: 2)
              )
        )
        .padding()
    }
}

#Preview {
    Slider(onActivate: {
        print("Triggered")
    }, message: "Slide to give up")
}
