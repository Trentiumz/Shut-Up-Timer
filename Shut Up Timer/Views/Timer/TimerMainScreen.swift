import SwiftUI
import CoreData

struct TimerMainScreen: View {
    let timerParam: TimerParam
    let iqChange: Double
    let selectedTodo: Todo?
    let onTaskTitleTap: () -> Void
    let onGiveUpTap: () -> Void
    let onCompleteTap: () -> Void
    let namespace: Namespace.ID
    let isSource: Bool
    
    @Environment(\.managedObjectContext) private var viewContext
    
    private var userCurrentIQ: Double {
        Session.getTotalIQ(context: viewContext) + iqChange
    }
    
    private func formatIQ(_ iq: Double) -> String {
        let integerPart = Int(iq)
        if integerPart >= 100 {
            return "\(integerPart)"
        } else {
            return String(format: "%.1f", iq)
        }
    }
    
    var body: some View {
        ZStack {
            // Top section with user IQ
            if isSource {
                GeometryReader { screen in
                    TimerBackgroundOverlay(screen: screen)
                }
                .ignoresSafeArea(.all)
            }
            
            if isSource {
                VStack {
                    HStack {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("\(formatIQ(userCurrentIQ)) IQ")
                                .font(FontTokens.architectsDaughter(size: 32))
                                .foregroundColor(.white)
                                .minimumScaleFactor(0.7)
                            Text(String(format: "+%.2f", iqChange))
                                .font(FontTokens.architectsDaughter(size: 14))
                                .foregroundColor(.white)
                                .minimumScaleFactor(0.7)
                        }
                        .padding()
                        Spacer()
                    }
                    Spacer()
                }
                .transition(.move(edge: .top))
            }
            
            VStack(spacing: 0) {
                Spacer()
                
                // Shared timer display (with matchedGeometryEffect)
                VStack(alignment: .center, spacing: 0) {
                    SharedTimerDisplay(timerParam: timerParam, namespace: namespace, isSource: isSource)
                    // Bottom section with task title and give up button
                    Button(action: onTaskTitleTap) {
                        HStack {
                            Rectangle()
                                .fill(selectedTodo?.goal?.realColor ?? ColorTokens.red300)
                                .frame(width: 4, height: 24)
                            
                            Text(selectedTodo?.todo ?? "No Task Selected")
                                .font(FontTokens.architectsDaughter(size: 24))
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        }
                        .padding(0)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                Spacer()
            }
        
            if isSource {
                // Give Up button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        switch(timerParam) {
                        case .countdown(_):
                            Button(action: onGiveUpTap) {
                                Text("Give Up")
                                    .font(FontTokens.architectsDaughter(size: 18))
                                    .foregroundColor(.black)
                                    .padding(.vertical, 14)
                                    .padding(.horizontal, 36)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(ColorTokens.shade200)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(.black, lineWidth: 2)
                                    )
                            }
                            .padding()
                        case .stopwatch(_):
                            Button(action: onCompleteTap) {
                                Text("Finish Session")
                                    .font(FontTokens.architectsDaughter(size: 18))
                                    .foregroundColor(.black)
                                    .padding(.vertical, 14)
                                    .padding(.horizontal, 36)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(ColorTokens.shade200)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(.black, lineWidth: 2)
                                    )
                            }
                            .padding()
                        }
                    }
                }
                .transition(.move(edge: .bottom))
            }
        }
    }
}

struct TimerBackgroundOverlay: View {
    let screen: GeometryProxy
    
    var body: some View {
        TriangleShape(points: (CGPoint(x: 0, y: 0), CGPoint(x: 0, y: screen.size.height / 4), CGPoint(x: screen.size.width, y: 0)))
            .fill(ColorTokens.red300)
        Path { path in
            path.move(to: CGPoint(x: 0, y: screen.size.height / 4))
            path.addLine(to: CGPoint(x: screen.size.width, y: 0))
        }
        .stroke(.white, lineWidth: 6)
        .transition(.move(edge: .top))
        
        TriangleShape(points: (CGPoint(x: 0, y: screen.size.height), CGPoint(x: screen.size.width, y: screen.size.height), CGPoint(x: screen.size.width, y: screen.size.height * 3 / 4)))
            .fill(ColorTokens.red300)
        Path { path in
            path.move(to: CGPoint(x: 0, y: screen.size.height))
            path.addLine(to: CGPoint(x: screen.size.width, y: screen.size.height * 3 / 4))
        }
        .stroke(.white, lineWidth: 6)
        .transition(.move(edge: .bottom))
    }
    
    struct TriangleShape: Shape {
        let points: (CGPoint, CGPoint, CGPoint)
        
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: points.0)
            path.addLine(to: points.1)
            path.addLine(to: points.2)
            path.closeSubpath()
            return path
        }
    }
}

struct TimerMainScreenPreview: PreviewProvider{
    struct Wrapper: View {
        @Namespace var namespace
        
        var body: some View {
            GeometryReader {screen in
                ZStack {
                    Background()
                    TimerMainScreen(
                        timerParam: .countdown(seconds: 1920), // 32 minutes
                        iqChange: 12,
                        selectedTodo: nil,
                        onTaskTitleTap: { },
                        onGiveUpTap: { },
                        onCompleteTap: {},
                        namespace: namespace,
                        isSource: false
                    )
                }
            }
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
        }
    }
    
    static var previews: some View {
        Wrapper()
    }
}
