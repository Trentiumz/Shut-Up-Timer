import SwiftUI;

struct TopBarView : View {
    @AppStorage("iq-points") var iqPts: Int = 0;
    
    var body: some View {
        HStack{
            Image(systemName: "star.fill")
                .font(.system(size: 32))
            Spacer()
            Text("IQ: \(iqPts)")
                .font(.system(size: 32))
        }
        .padding()
        .background(Color(red: 0.9, green: 0.9, blue: 0.9))
    }
}

#Preview {
    VStack {
        TopBarView()
        Spacer()
    }
}
