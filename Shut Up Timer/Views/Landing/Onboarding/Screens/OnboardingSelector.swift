import SwiftUI;

struct OnboardingSelector : View {
    var text: String;
    var selectedText: String?;
    var isSelected: Bool;
    var onSelect: () -> Void;
    
    var isSmall: Bool = false;
    
    var body : some View {
        if !isSmall {
            Button(action: {
                if(!isSelected) {
                    onSelect();
                }
            }){
                ZStack {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 328, height: 74)
                        .background(isSelected ? ColorTokens.red300 : ColorTokens.shade200)
                        .cornerRadius(30)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .inset(by: 1)
                                .stroke(isSelected ? ColorTokens.shade700 : ColorTokens.red300, lineWidth: 2)
                        )
                    
                    Text(isSelected ? (selectedText ?? text) : text)
                        .font(Font.custom("ArchitectsDaughter-Regular", size: 30))
                        .foregroundColor(isSelected ? ColorTokens.shade100 : ColorTokens.red300)
                        .frame(width: 280, height: 50)
                        .minimumScaleFactor(0.2)
                        .lineLimit(2)
                }
            }
        } else {
            Button(action: {
                if(!isSelected) {
                    onSelect();
                }
            }){
                ZStack {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 328, height: 52)
                        .background(isSelected ? ColorTokens.red300 : ColorTokens.shade200)
                        .cornerRadius(30)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .inset(by: 1)
                                .stroke(isSelected ? ColorTokens.shade700 : ColorTokens.red300, lineWidth: 2)
                        )
                    Text(isSelected ? (selectedText ?? text) : text)
                        .font(Font.custom("ArchitectsDaughter-Regular", size: 30))
                        .foregroundColor(isSelected ? ColorTokens.shade100 : ColorTokens.red300)
                        .frame(width: 280, height: 44)
                        .minimumScaleFactor(0.2)
                        .lineLimit(2)
                }
            }
        }
    }
}

struct OnboardingNextButton: View {
    var text: String;
    var onSelect: () -> Void;
    var isSmall: Bool = false;
    
    var body : some View {
        if !isSmall {
            Button(action: {
                onSelect();
            }){
                ZStack {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 328, height: 74)
                        .background(ColorTokens.red300)
                        .cornerRadius(30)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .inset(by: 1)
                                .stroke(ColorTokens.shade700, lineWidth: 2)
                        )
                    Text(text)
                        .font(Font.custom("ArchitectsDaughter-Regular", size: 30))
                        .foregroundColor(ColorTokens.shade100)
                        .frame(width: 280, height: 50)
                        .minimumScaleFactor(0.2)
                        .lineLimit(2)
                }
            }
        } else {
            Button(action: {
                onSelect();
            }){
                ZStack {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 328, height: 52)
                        .background(ColorTokens.red300)
                        .cornerRadius(30)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .inset(by: 1)
                                .stroke(ColorTokens.shade700, lineWidth: 2)
                        )
                    
                    Text(text)
                        .font(Font.custom("ArchitectsDaughter-Regular", size: 30))
                        .foregroundColor(ColorTokens.shade100)
                        .frame(width: 280, height: 44)
                        .minimumScaleFactor(0.2)
                        .lineLimit(2)
                }
            }
        }
    }
}

#Preview {
    VStack {
        OnboardingSelector(text: "Hello", selectedText: "nope", isSelected: false, onSelect: {})
        OnboardingNextButton(text: "whoop", onSelect: {})
    }
}
