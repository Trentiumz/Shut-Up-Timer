import SwiftUI;

class LBEntry : ObservableObject, Identifiable{
    let id = UUID()
    @Published var name: String;
    @Published var pts: Int;
    
    init(name: String, pts: Int) {
        self.name = name
        self.pts = pts
    }
}
