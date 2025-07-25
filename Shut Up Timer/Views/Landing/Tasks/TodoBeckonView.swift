import SwiftUI

struct TodoBeckonView: View {
    @State private var currentScreen = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Main content area with TabView and navigation arrows
            HStack(spacing: 0) {
                // Left arrow
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentScreen = max(0, currentScreen - 1)
                    }
                }) {
                    RoundedTriangle(direction: .left)
                        .fill(Color.gray)
                        .frame(width: 20, height: 80)
                }
                .opacity(currentScreen > 0 ? 1 : 0)
                .disabled(currentScreen == 0)
                .padding(.leading, 10)
                
                // TabView
                TabView(selection: Binding<Int> (
                    get: { return currentScreen },
                    set: { val in
                        withAnimation {
                            currentScreen = val
                        }
                    }
                )) {
                    // Screen 1 - Summary screen
                    SummaryScreen()
                        .tag(0)
                    
                                         // Screen 2 - Phone screen
                     PhoneBeckon()
                         .tag(1)
                    
                    // Screen 3 - Placeholder
                    TaskPoke()
                        .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Right arrow
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentScreen = min(2, currentScreen + 1)
                    }
                }) {
                    RoundedTriangle(direction: .right)
                        .fill(Color.gray)
                        .frame(width: 20, height: 80)
                }
                .opacity(currentScreen < 2 ? 1 : 0)
                .disabled(currentScreen == 2)
                .padding(.trailing, 10)
            }
            
            // Bottom indicators
            HStack(spacing: 8) {
                ForEach(0..<3) { index in
                    RoundedRectangle(cornerRadius: currentScreen == index ? 12 : 6)
                        .fill(Color.secondary)
                        .frame(
                            width: currentScreen == index ? 48 : 12,
                            height: 12
                        )
                        .animation(.easeInOut(duration: 0.2), value: currentScreen)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentScreen = index
                            }
                        }
                        .overlay {
                            RoundedRectangle(cornerRadius: currentScreen == index ? 12 : 6)
                                .stroke(ColorTokens.shade100, lineWidth: 2)
                        }
                }
            }
            .padding(.bottom, 20)
            .padding(.top, 20)
        }
    }
}

fileprivate struct SummaryScreen: View {
    var body: some View {
        HStack(spacing: 0) {
            // Grandma image on the left
            Rectangle()
                .fill(Color.clear)
                .overlay(
                    Image(uiImage: FormattedImages.Image161)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .offset(x: 30)
                    ,
                    alignment: .trailing
                )
                .zIndex(2)
            
            // Info card on the right
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.gray.opacity(0.8))
                .overlay (
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(ColorTokens.shade100, lineWidth: 2)
                )
                .overlay(
                    VStack(alignment: .trailing) {
                        // Identity
                        HStack(spacing: 5) {
                            Spacer()
                            Text("Identity:")
                                .font(FontTokens.architectsDaughter(size: 18))
                                .foregroundColor(ColorTokens.shade100)
                            Text("Mom")
                                .font(FontTokens.architectsDaughter(size: 16))
                                .foregroundColor(ColorTokens.shade700)
                            Spacer()
                        }
                        .layoutPriority(1)
                        
                        Spacer()
                            .frame(maxHeight: 25)
                        
                        // Catchphrase
                        VStack(alignment: .trailing, spacing: 5) {
                            Text("Catchphrase:")
                                .font(FontTokens.architectsDaughter(size: 16))
                                .foregroundColor(ColorTokens.shade100)
                                .lineLimit(1)
                            Text("\"hey cant you be better haha you old cousin Jenny?\"")
                                .font(FontTokens.architectsDaughter(size: 12))
                                .foregroundColor(ColorTokens.shade700)
                                .lineLimit(3)
                                .frame(idealHeight: 65, alignment: .top)
                                .layoutPriority(1)
                        }
                        .padding(.leading, 30)
                        .layoutPriority(1)
                        
                        Spacer()
                            .frame(maxHeight: 25)
                        
                        // Patience Level
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Patience Level")
                                .font(FontTokens.architectsDaughter(size: 16))
                                .foregroundColor(ColorTokens.shade100)
                            
                            // Progress bar
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(ColorTokens.shade700)
                                        .frame(width: geo.size.width, height: 20)
                                    
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(ColorTokens.red200)
                                        .frame(width: geo.size.width * 0.7, height: 20)
                                    
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(ColorTokens.shade100, lineWidth: 2)
                                        .frame(width: geo.size.width, height: 20)
                                }
                                .frame(height: 20)
                            }
                            .frame(height: 20)
                        }
                        .layoutPriority(1)
                    }
                    .padding(15)
                )
                .frame(maxWidth: 160, maxHeight: 250)
                .layoutPriority(1)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.trailing, 20)
    }
}

fileprivate struct PhoneBeckon: View {
    var body: some View {
        ZStack {
            // Mom image positioned at bottom left
            VStack {
                Spacer()
                HStack {
                    ViewThatFits {
                        // Large size
                        Image(uiImage: FormattedImages.Image164)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    }
                    Spacer()
                        .frame(maxWidth: 80)
                }
                .padding(.leading, 20)
            }
            
            // Message box positioned at bottom right
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    
                    Text("stop scrolling ur phone")
                        .font(FontTokens.architectsDaughter(size: 16))
                        .foregroundColor(ColorTokens.shade100)
                        .multilineTextAlignment(.center)
                        .padding()
                        .lineLimit(3)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(ColorTokens.brown500)
                                .overlay (
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(ColorTokens.shade100, lineWidth: 4)
                                )
                        )
                }
                .padding(.trailing, 20)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 300)
    }
}

fileprivate struct TaskPoke: View {
    var body: some View {
        Group {
            // Mom image positioned at bottom left
            Image(uiImage: FormattedImages.Image166)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: 300)
    }
}

struct RoundedTriangle: Shape {
    enum Direction {
        case left, right
    }
    
    let direction: Direction
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let cornerRadius: CGFloat = 4
        
        switch direction {
        case .left:
            // Left-pointing triangle
            path.move(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.minX + cornerRadius, y: rect.midY - cornerRadius))
            path.addQuadCurve(to: CGPoint(x: rect.minX + cornerRadius, y: rect.midY + cornerRadius),
                            control: CGPoint(x: rect.minX, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.maxY))
            path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.maxY - cornerRadius),
                            control: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + cornerRadius))
            path.addQuadCurve(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY),
                            control: CGPoint(x: rect.maxX, y: rect.minY))
            
        case .right:
            // Right-pointing triangle
            path.move(to: CGPoint(x: rect.minX + cornerRadius, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.midY - cornerRadius))
            path.addQuadCurve(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.midY + cornerRadius),
                            control: CGPoint(x: rect.maxX, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY))
            path.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.maxY - cornerRadius),
                            control: CGPoint(x: rect.minX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + cornerRadius))
            path.addQuadCurve(to: CGPoint(x: rect.minX + cornerRadius, y: rect.minY),
                            control: CGPoint(x: rect.minX, y: rect.minY))
        }
        
        path.closeSubpath()
        return path
    }
}

#Preview {
    ZStack {
        Background()
        TodoBeckonView()
            .preferredColorScheme(.light)
    }
}
