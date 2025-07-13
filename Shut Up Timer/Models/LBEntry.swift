import SwiftUI
import Combine

class LBEntry: ObservableObject, Identifiable {
    let id = UUID()
    @Published var name: String {
        didSet {
            didChange.send(self)
        }
    }
    @Published var pts: Int {
        didSet {
            didChange.send(self)
        }
    }
    @Published var profilePicture: String {
        didSet {
            didChange.send(self)
        }
    }
    let didChange = PassthroughSubject<LBEntry, Never>()
    
    init(name: String, pfp: String, pts: Int) {
        self.name = name
        self.pts = pts
        self.profilePicture = pfp
    }
}
