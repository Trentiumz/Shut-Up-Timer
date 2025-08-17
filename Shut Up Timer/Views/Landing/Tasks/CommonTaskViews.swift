import SwiftUI

struct CommonTaskViews {
    struct CancelButton: View {
        let onCancel: () -> Void
        
        var body: some View {
            Button(action: onCancel) {
                Text("Cancel >")
                    .font(FontTokens.architectsDaughter(size: 16))
                    .foregroundColor(ColorTokens.shade400)
                    .minimumScaleFactor(0.6)
                    .padding(.vertical, 8)
            }
        }
    }
}
