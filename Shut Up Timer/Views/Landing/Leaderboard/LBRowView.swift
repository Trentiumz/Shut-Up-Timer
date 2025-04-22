import SwiftUI;

struct LBRowView : View {
    private var name: String;
    private var pts : Int;
    
    init(name: String, pts: Int) {
        self.name = name
        self.pts = pts
    }
    
    var body: some View {
        Text("\(name) with \(pts) points")
    }
}

#Preview {
    LBRowView(name: "Trent", pts: 50);
}
