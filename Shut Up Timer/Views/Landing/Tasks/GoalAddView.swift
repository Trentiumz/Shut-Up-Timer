import SwiftUI

struct TemporaryGoal {
    var color: Color = randomGoalColor()
    var name: String = ""
    var iqGoal: Double = 0
    var weeksNeeded: Double = 0
    var hoursPerWeek: Double = 0
}

func randomGoalColor(unlike: Color? = nil) -> Color {
    return Color.init(hue: Double(Int.random(in: 0..<21)) / 20, saturation: [0.5, 1.0].randomElement()!, brightness: 1)
}

struct GoalAddView: View {
    @State private var currentScreen = 0
    @State private var temporaryGoal = TemporaryGoal()
    let onGoalAdded: (TemporaryGoal) -> Void
    
    var body: some View {
        switch(currentScreen) {
        case 0:
            // Screen 1 - Goal Setup
            GoalSetupScreen(temporaryGoal: $temporaryGoal, onNext: {
                withAnimation {
                    currentScreen = 1
                }
            })
            .transition(.opacity)
        case 1:
            // Screen 2 - Hours Calculator
            HoursCalculatorScreen(hoursPerWeek: $temporaryGoal.hoursPerWeek, onNext: {
                withAnimation {
                    currentScreen = 2
                }
            })
            .transition(.opacity)
        case 2:
            // Screen 3 - Weeks Calculator
            WeeksCalculatorScreen(weeksNeeded: $temporaryGoal.weeksNeeded, onNext: {
                withAnimation {
                    temporaryGoal.iqGoal = temporaryGoal.hoursPerWeek * temporaryGoal.weeksNeeded;
                    currentScreen = 3
                }
            })
            .transition(.opacity)
        default:
                         // Screen 4 - Summary
             GoalSummaryScreen(temporaryGoal: $temporaryGoal, onComplete: {
                 onGoalAdded(temporaryGoal)
             })
            .transition(.opacity)
        }
    }
}

// MARK: - Screen 1: Goal Setup
fileprivate struct GoalSetupScreen: View {
    @Binding var temporaryGoal: TemporaryGoal
    let onNext: () -> Void
    
    var body: some View {
        DarkContentContainer {
            VStack {
                Text("Add Goal")
                    .font(FontTokens.architectsDaughter(size: 24))
                    .foregroundColor(.white)
                
                Spacer()
                
                // Color selector
                HStack {
                    Text("Select Color: ")
                        .font(FontTokens.architectsDaughter(size: 18))
                        .foregroundColor(.white)
                    
                    Spacer()
                        .frame(maxWidth: 15)
                    
                    Rectangle()
                        .fill(temporaryGoal.color)
                        .frame(width: 80, height: 40)
                        .cornerRadius(8)
                        .onTapGesture {
                            temporaryGoal.color = randomGoalColor()
                        }
                }
                
                Spacer()
                
                // Name input
                VStack {
                    Text("Goal Name")
                        .font(FontTokens.architectsDaughter(size: 18))
                        .foregroundColor(.white)
                    
                    Spacer()
                        .frame(maxHeight: 15)
                    
                    TextField("Enter goal name", text: $temporaryGoal.name)
                        .font(FontTokens.architectsDaughter(size: 16))
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.3))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                                )
                        )
                }
                
                Spacer()
                
                // Next button
                ViewThatFits {
                    Button(action: onNext) {
                        Text("Next")
                            .font(FontTokens.architectsDaughter(size: 18))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(ColorTokens.red300)
                            )
                    }
                    
                    Button(action: onNext) {
                        Text("Next")
                            .font(FontTokens.architectsDaughter(size: 18))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(ColorTokens.red300)
                            )
                    }
                    
                    Button(action: onNext) {
                        Text("Next")
                            .font(FontTokens.architectsDaughter(size: 18))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(ColorTokens.red300)
                            )
                    }
                }
                .disabled(temporaryGoal.name.isEmpty)
                .opacity(temporaryGoal.name.isEmpty ? 0.5 : 1.0)
            }
            .padding(20)
        }
    }
}

// MARK: - Screen 2: Hours Calculator
fileprivate struct HoursCalculatorScreen: View {
    @Binding var hoursPerWeek: Double;
    let onNext: () -> Void
    
    var body: some View {
        DarkContentContainer {
            VStack(spacing: 0) {
                Spacer()
                
                CalculatorComponent(value: _hoursPerWeek, placeholder: "How many hrs would you spend on this for a week?", onEnter: onNext)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            .padding(.top, 10)
        }
    }
}

// MARK: - Screen 3: Weeks Calculator
fileprivate struct WeeksCalculatorScreen: View {
    @Binding var weeksNeeded: Double
    let onNext: () -> Void
    
    var body: some View {
        DarkContentContainer {
            VStack(spacing: 20) {
                Spacer()
                
                CalculatorComponent(value: _weeksNeeded, placeholder: "How many weeks do you need to accomplish this goal?", onEnter: onNext)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            .padding(.top, 10)
        }
    }
}

// MARK: - Screen 4: Summary
fileprivate struct GoalSummaryScreen: View {
    @Binding var temporaryGoal: TemporaryGoal
    let onComplete: () -> Void
    
    private var formatter: NumberFormatter {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.maximumFractionDigits = 4
        nf.minimumFractionDigits = 0
        nf.usesGroupingSeparator = false
        return nf
    }
    
    var body: some View {
        DarkContentContainer {
            VStack {
                Text("Goal Summary")
                    .font(FontTokens.architectsDaughter(size: 24))
                    .foregroundColor(.white)
                
                Spacer()
                
                // Goal display
                VStack(spacing: 20) {
                    HStack {
                        Rectangle()
                            .fill(temporaryGoal.color)
                            .frame(width: 40, height: 40)
                            .cornerRadius(8)
                        
                        Text(temporaryGoal.name)
                            .font(FontTokens.architectsDaughter(size: 20))
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("iq Goal: ")
                                .font(FontTokens.architectsDaughter(size: 16))
                                .foregroundColor(.white)
                            TextField(String(format: "%.1f (%.1f weeks x %.1f hrs)", temporaryGoal.hoursPerWeek * temporaryGoal.weeksNeeded, temporaryGoal.weeksNeeded, temporaryGoal.hoursPerWeek), value: $temporaryGoal.iqGoal, formatter: formatter)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(.roundedBorder)
                                .font(FontTokens.architectsDaughter(size: 16))
                        }
                    }
                }
                .padding()
                
                Spacer()
                
                // Complete button
                Button(action: onComplete) {
                    Text("Create Goal")
                        .font(FontTokens.architectsDaughter(size: 18))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(ColorTokens.red300)
                        )
                }
            }
            .padding(20)
        }
    }
}

// MARK: - Calculator Component
fileprivate struct CalculatorComponent: View {
    @Binding var value: Double
    @State private var displayText: String = ""
    let placeholder: String;
    let onEnter: () -> Void
    
    var body: some View {
        VStack {
            // Display
            ZStack(alignment: .trailing) {
                HStack {
                    Spacer()
                    Text(placeholder)
                        .font(FontTokens.architectsDaughter(size: 18))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.trailing)
                        .minimumScaleFactor(0.7)
                        .lineLimit(2)
                }
                .opacity(displayText.isEmpty ? 1 : 0)
                .allowsHitTesting(displayText.isEmpty)
                
                HStack {
                    Spacer()
                    Text(displayText)
                        .font(FontTokens.architectsDaughter(size: 24))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .lineLimit(1)
                }
                .opacity(!displayText.isEmpty ? 1 : 0)
                .allowsHitTesting(!displayText.isEmpty)
            }
            .frame(height: 42)
            
            Spacer()
                .frame(maxHeight: 20)
            
            // Calculator buttons
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 6) {
                 ForEach(calculatorButtons, id: \.self) { button in
                     Button(action: {
                         handleButtonPress(button)
                     }) {
                         Text(button)
                             .font(FontTokens.architectsDaughter(size: 24))
                             .foregroundColor(.white)
                     }
                     .buttonStyle(CalculatorButtonStyle())
                 }
             }
            .layoutPriority(1)
            
            Spacer()
            
            // Enter button
            Button(action: {
                if let newValue = Double(displayText) {
                    value = newValue
                }
                onEnter()
            }) {
                ViewThatFits {
                    Text("Enter")
                        .font(FontTokens.architectsDaughter(size: 18))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(ColorTokens.red300)
                        )
                    
                    Text("Enter")
                        .font(FontTokens.architectsDaughter(size: 18))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(ColorTokens.red300)
                        )
                }
            }
        }
    }
    
    private let calculatorButtons = [
        "9", "8", "7", "X",
        "6", "5", "4", ".",
        "3", "2", "1", "0"
    ]
    
    private func handleButtonPress(_ button: String) {
        var candidate = displayText;
        switch button {
        case "X":
            if !candidate.isEmpty {
                candidate.removeLast()
            }
        case ".":
            if !candidate.contains(".") {
                candidate += "."
            }
        default:
            candidate += button
        }
        
        if let newValue = Double(candidate) {
            value = newValue;
        }
        if button == "X" || Double(candidate) != nil {
            displayText = candidate;
        }
    }
}

// MARK: - Supporting Views
struct DarkContentContainer<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white, lineWidth: 2)
                )
                .overlay(content)
        }
    }
}

fileprivate struct CalculatorButtonStyle: ButtonStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.6))
                    .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            )
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    ZStack {
        Color.black
        GoalAddView { _ in
            // Preview handler
        }
    }
    .frame(height: 300)
}
