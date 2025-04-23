import SwiftUI;
import UIKit

// A generic duration picker
struct DurationPicker: UIViewRepresentable {
    @Binding var duration: TimeInterval

    func makeUIView(context: Context) -> UIDatePicker {
        let picker = UIDatePicker()
        picker.datePickerMode = .countDownTimer
        picker.countDownDuration = duration
        picker.addTarget(context.coordinator, action: #selector(Coordinator.updateDuration(_:)), for: .valueChanged)
        return picker
    }

    func updateUIView(_ uiView: UIDatePicker, context: Context) {
        uiView.countDownDuration = duration
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(duration: $duration)
    }

    class Coordinator: NSObject {
        var duration: Binding<TimeInterval>

        init(duration: Binding<TimeInterval>) {
            self.duration = duration
        }

        @objc func updateDuration(_ sender: UIDatePicker) {
            duration.wrappedValue = sender.countDownDuration
        }
    }
}

// a modal for selecting duration
struct DurationPickerModal: View {
    @Binding var duration: TimeInterval
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Text("Select Duration")
                .font(.headline)

            DurationPicker(duration: $duration)
                .frame(maxHeight: 200)

            Button("Done") {
                dismiss()
            }
            .font(.headline)
            .padding(.top, 10)

            Spacer()
        }
        .padding()
    }
}

#Preview {
    @Previewable @State var thing = TimeInterval();
    DurationPickerModal(duration: $thing)
}
