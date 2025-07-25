import SwiftUI
import CoreData

struct AlbumView: View {
    @EnvironmentObject var sessions: SessionLoader
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedTab: AlbumTab = .month
    
    let month: Int
    let year: Int
    
    // Fetch all sessions and filter in computed properties
    @FetchRequest(
        entity: Session.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Session.started, ascending: false)]
    ) private var allSessions: FetchedResults<Session>
    
    // Computed property for month sessions
    var monthSessions: [Session] {
        let startDate = Calendar.current.date(from: DateComponents(year: year, month: month)) ?? Date()
        let endDate = Calendar.current.date(byAdding: .month, value: 1, to: startDate) ?? Date()
        
        return allSessions.filter { session in
            guard let sessionDate = session.started else { return false }
            return sessionDate >= startDate && sessionDate < endDate
        }
    }
    
    // Computed property for year sessions
    var yearSessions: [Session] {
        let startDate = Calendar.current.date(from: DateComponents(year: year)) ?? Date()
        let endDate = Calendar.current.date(byAdding: .year, value: 1, to: startDate) ?? Date()
        
        return allSessions.filter { session in
            guard let sessionDate = session.started else { return false }
            return sessionDate >= startDate && sessionDate < endDate
        }
    }
    
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

    // Get current sessions based on selected tab
    var currentSessions: [Session] {
        return selectedTab == .month ? monthSessions : yearSessions
    }

    // Get images for display (most recent first)
    func getImages() -> [(String, Session)] {
        return currentSessions.compactMap { session in
            if let imageName = session.imageName {
                return (imageName, session)
            }
            return nil
        }
    }

    // Get roasts for display (most recent first)
    func getRoasts() -> [(String, Session)] {
        return currentSessions.compactMap { session in
            if let roast = session.roast {
                return (roast, session)
            }
            return nil
        }
    }

    /// returns items, which is either ("image", image name, Session) or ("roast", roast, Session)
    func getItems() -> [(String, String, Session)] {
        var entries = getImages().map { ("image", $0.0, $0.1 )} + getRoasts().map{ ("roast", $0.0, $0.1 )}
        entries = entries.sorted{ ($0.2.started ?? Date()) > ($1.2.started ?? Date()) }
        return entries
    }
    
    func removeRoast(session: Session) {
        session.roast = nil
        do {
            try viewContext.save()
        } catch {
            print("Failed to remove roast: \(error)")
        }
    }

    func removeImage(session: Session) {
        if let imageName = session.imageName {
            _ = ImageLoader.deleteImage(name: imageName)
            session.imageName = nil
            do {
                try viewContext.save()
            } catch {
                print("Failed to remove image: \(error)")
            }
        }
    }
    
    struct ImagesRow : View {
        var items: [(String, String, Session)]
        var removeImage: (Session) -> Void
        var removeRoast: (Session) -> Void
        
        var body : some View {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 18) {
                    ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                        if item.0 == "image" {
                            if let image = ImageLoader.loadImage(name: item.1) {
                                PostImageDisplay(image: image)
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            removeImage(item.2)
                                        } label: {
                                            Label("Remove Image", systemImage: "trash")
                                        }
                                    }
                            }
                        } else {
                            RoastDisplay(message: item.1)
                                .contextMenu {
                                    Button(role: .destructive) {
                                        removeRoast(item.2)
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
        .environmentObject(SessionLoader())
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
