import SwiftUI

struct AddFeedbackView: View {
    @Binding var isPresented: Bool
    @State private var stars: Int = 0
    @State private var feedbackText: String = ""
    
    var onSubmit: ((Int, String) -> Void)?
    
    var body: some View {
        VStack(spacing: 24) {
            // Star selection
            HStack(spacing: 8) {
                ForEach(1...5, id: \.self) { i in
                    Image(systemName: i <= stars ? "star.fill" : "star")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(ColorTokens.red300)
                        .onTapGesture {
                            stars = i
                        }
                        .accessibilityLabel("\(i) star\(i > 1 ? "s" : "")")
                }
            }
            
            // Feedback text field
            TextEditor(text: $feedbackText)
                .font(FontTokens.architectsDaughter(size: 20))
                .foregroundColor(ColorTokens.shade700)
                .frame(minHeight: 120, maxHeight: 200)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(ColorTokens.shade300, lineWidth: 2)
                )
                .background(ColorTokens.shade100)
                .cornerRadius(12)
                .padding(.horizontal)
            
            // Submit & Cancel buttons
            HStack(spacing: 24) {
                Button("Cancel") {
                    isPresented = false
                }
                .font(FontTokens.architectsDaughter(size: 20))
                .foregroundColor(ColorTokens.shade700)
                
                Button("Submit") {
                    if stars > 0 && !feedbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        onSubmit?(stars, feedbackText)
                        isPresented = false
                    }
                }
                .font(FontTokens.architectsDaughter(size: 20))
                .foregroundColor(ColorTokens.red300)
                .disabled(stars == 0 || feedbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.top, 8)
        }
        .padding()
    }
}

#Preview {
    AddFeedbackView(isPresented: .constant(true))
}