import SwiftUI

struct AlbumView: View {
    @EnvironmentObject var sessions: Sessions
    @State private var selectedTab: AlbumTab = .month
    
    let month: Int
    let year: Int
    
    func getMonthString() -> String {
        let formatter = DateFormatter()
        return formatter.monthSymbols[month - 1]
    }
    
    func getYearString() -> String {
        return String(year)
    }

    enum AlbumTab: String, CaseIterable, Identifiable {
        case month = "Month"
        case year = "Year"
        var id: String { self.rawValue }
    }

    // Placeholder: Get sessions for current month
    func getMonthSessions() -> [SessionEntry] {
        var monthSessions : [SessionEntry] = []
        if let startDate = Calendar.current.date(from: DateComponents(year: year, month: month)) {
            monthSessions = sessions.sessions.filter { $0.started >= startDate && $0.started < Calendar.current.date(byAdding: .month, value: 1, to: startDate)! }
        } else {
            print("Failed to get start date from month \(month) and year \(year)")
        }
        // Replace with real filtering logic
        return monthSessions.sorted { $0.started > $1.started }
    }

    // Placeholder: Get sessions for current year
    func getYearSessions() -> [SessionEntry] {
        var yearSessions : [SessionEntry] = []
        if let startDate = Calendar.current.date(from: DateComponents(year: year)) {
            yearSessions = sessions.sessions.filter { $0.started >= startDate && $0.started < Calendar.current.date(byAdding: .year, value: 1, to: startDate)! }
        } else {
            print("Failed to get start date from month \(month) and year \(year)")
        }
        // Replace with real filtering logic
        return yearSessions.sorted { $0.started > $1.started }
    }

    // Get images for display (most recent first)
    func getImages() -> [(String, SessionEntry)] {
        let entries = selectedTab == .month ? getMonthSessions() : getYearSessions()
        return entries.compactMap { entry in
            if let imageName = entry.imageName {
                return (imageName, entry)
            } else {
                return nil
            }
        }
    }

    // Get roasts for display (most recent first)
    func getRoasts() -> [(String, SessionEntry)] {
        let entries = selectedTab == .month ? getMonthSessions() : getYearSessions()
        return entries.compactMap { entry in
            if let roast = entry.roast {
                return (roast, entry)
            } else {
                return nil
            }
        }
    }
    
    /// returns items, which is either ("image", image name, Session) or ("roast", roast, Session)
    func getItems() -> [(String, String, SessionEntry)] {
        var entries = getImages().map { ("image", $0.0, $0.1 )} + getRoasts().map{ ("roast", $0.0, $0.1 )}
        entries = entries.sorted{ $0.2.started > $1.2.started }
        return entries
    }
    
    func removeRoast(id: UUID) {
        if let ind = sessions.sessions.firstIndex(where: { $0.id == id }) {
            sessions.sessions[ind].roast = nil
        }
    }
    
    func removeImage(id: UUID) {
        if let ind = sessions.sessions.firstIndex(where: { $0.id == id }) {
            _ = ImageLoader.deleteImage(name: sessions.sessions[ind].imageName!)
            sessions.sessions[ind].imageName = nil
        }
    }
    
    struct ImagesRow : View {
        var items: [(String, String, SessionEntry)]
        var removeImage: (UUID) -> Void
        var removeRoast: (UUID) -> Void
        
        var body : some View {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 18) {
                    ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                        if item.0 == "image" {
                            if let image = ImageLoader.loadImage(name: item.1) {
                                FailImageDisplay(image: image)
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            removeImage(item.2.id)
                                        } label: {
                                            Label("Remove Image", systemImage: "trash")
                                        }
                                    }
                            }
                        } else {
                            RoastDisplay(message: item.1)
                                .contextMenu {
                                    Button(role: .destructive) {
                                        removeRoast(item.2.id)
                                    } label: {
                                        Label("Remove Roast", systemImage: "trash")
                                    }
                                }
                        }
                    }
                }
                .padding(.horizontal, 10)
            }
            .frame(height: 170)
        }
    }
    
    var body: some View {
        ZStack {
            Background()
            ScrollView {
                VStack(alignment: .center, spacing: 0) {
                    
                    // --- Month/Year Label ---
                    HStack {
                        SectionStripe(selectedTab == .month ? "\(getMonthString()) \(getYearString()) >" : "\(getYearString()) >")
                            .padding(.bottom, 4)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    
                    // --- Images Row ---
                    ImagesRow(items: getItems(), removeImage: removeImage, removeRoast: removeRoast)
                    
                    Spacer()
                        .frame(height: 60)
                    
                    // --- Roasts Section ---
                    ZStack(alignment: .topLeading) {
                        FormattedImages.LinedImageBackground(width: 350)
                            .cornerRadius(18)
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Spacer()
                                    .frame(maxWidth: 20)
                                Text("Favourite Roasts")
                                    .font(FontTokens.architectsDaughter(size: 30))
                                    .foregroundColor(.black)
                                    .frame(width: 270, alignment: .topLeading)
                            }
                            ForEach(Array(getRoasts().prefix(2).enumerated()), id: \.offset) { _, roast in
                                HStack(spacing: 8) {
                                    Spacer()
                                        .frame(maxWidth: 10)
                                    Image(systemName: "flame.fill")
                                        .foregroundColor(.red)
                                    Text(roast.0)
                                        .font(FontTokens.architectsDaughter(size: 16))
                                        .foregroundColor(.black)
                                        .minimumScaleFactor(0.5)
                                        .frame(width: 225.00002, height: 60, alignment: .topLeading)
                                }
                            }
                            Spacer()
                        }
                        .padding(.top, 18)
                        .padding(.leading, 24)
                    }
                    .frame(width: 340, height: 210)
                    .padding(.top, 8)
                    
                    Spacer()
                        .frame(height: 60)
                    
                    // --- Tabs ---
                    HStack(spacing: 0) {
                        ForEach(AlbumTab.allCases) { tab in
                            ZStack(alignment: .center) {
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .frame(width: 120, height: 41)
                                    .background(selectedTab == tab ? ColorTokens.red300 : ColorTokens.shade300)
                                    .overlay(
                                        Rectangle()
                                            .inset(by: 1)
                                            .stroke(ColorTokens.shade700, lineWidth: 2)
                                    )
                                Text(tab.rawValue)
                                    .font(FontTokens.architectsDaughter(size: 20))
                                    .foregroundColor(selectedTab == tab ? ColorTokens.shade100 : ColorTokens.shade700)
                            }
                            .onTapGesture {
                                withAnimation {
                                    selectedTab = tab
                                }
                            }
                        }
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 8)
                    
                    Spacer()
                }
                .frame(maxHeight: .infinity)
                .padding(.horizontal, 12)
                .padding(.top, 8)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    AlbumView(month: Calendar.current.component(.month, from: Date()),
              year: Calendar.current.component(.year, from: Date()))
        .environmentObject(Sessions(sessions: [
            SessionEntry(tasks: [], started: Calendar.current.date(from: DateComponents(year: 2025, month: 1))!, ended: Date(), timeLocked: 3600.0, plannedTime: 0, success: false, roast: "You're one more '5-minute break' away from complete academic collapse.", imageName: "onboarding-hello-image 65"),
            SessionEntry(tasks: [], started: Date().addingTimeInterval(-86400), ended: Date(), timeLocked: 3600.0, plannedTime: 0, success: false, roast: "Your brain's in power-saving mode and it shows.", imageName: "onboarding-hello-image 67"),
            SessionEntry(tasks: [], started: Date().addingTimeInterval(-172800), ended: Date(), timeLocked: 3600.0, plannedTime: 0, success: false, roast: "At this point, your to-do list is fiction.", imageName: "onboarding-hello-image 68"),
            SessionEntry(tasks: [], started: Date().addingTimeInterval(-259200), ended: Date(), timeLocked: 3600.0, plannedTime: 0, success: false, roast: "You have more breaks than work.", imageName: "onboarding-hello-image 70")
        ], onUpdate: {_ in }))
}
