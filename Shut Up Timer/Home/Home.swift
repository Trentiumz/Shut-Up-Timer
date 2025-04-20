import SwiftUI

struct Home: View {
    var body: some View {
        VStack {

            Spacer()  // Push the content down

            // Circle button in the center of the screen
            Button(action: {
                // Action for the button (can navigate or do something)
                print("Circle button pressed!")
            }) {
                Circle()
                    .fill(Color.blue)  // Circle color
                    .frame(width: 150, height: 150)  // Size of the circle
                    .overlay(
                        Text("Tap Me")
                            .foregroundColor(.white)
                            .font(.headline)
                    )
            }

            Spacer()  // Push content up from the bottom
            Navbar()  // Add the Navbar at the top
        }
        .padding()  // Padding around the screen
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}

