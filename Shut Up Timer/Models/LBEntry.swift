import SwiftUI;

class LBEntry : ObservableObject, Identifiable{
    let id = UUID()
    @Published var name: String;
    @Published var pts: Int;
    @Published var profilePicture: String;
    
    init(name: String, pfp: String, pts: Int) {
        self.name = name
        self.pts = pts
        self.pfp = pfp
    }
}
