import SwiftUI

struct Navbar: View {
    var body: some View {
        HStack {
            Text("Navbar")
                .font(.title)
                .foregroundColor(.white)
            Spacer()
        }
        .padding()
        .frame(height: 60)  // Define the height of the navbar
        .background(Color.black)  // Navbar background color
    }
}

struct Navbar_Previews: PreviewProvider {
    static var previews: some View {
        Navbar()
            .previewLayout(.sizeThatFits)  // To preview the navbar independently
    }
}
