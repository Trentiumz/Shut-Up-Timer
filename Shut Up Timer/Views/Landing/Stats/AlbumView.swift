import SwiftUI
import CoreData

// Peculiar Image Button View
struct AlbumViewButtonIcon: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    // Fetch the most recent session with an image
    @FetchRequest(
        entity: Session.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Session.started, ascending: false)],
        predicate: NSPredicate(format: "imageName != nil")
    ) private var sessionsWithImages: FetchedResults<Session>
    
    var mostRecentImage: UIImage? {
        guard let session = sessionsWithImages.first,
              let imageName = session.imageName else { return nil }
        return ImageLoader.loadImage(name: imageName)
    }
    
    var body: some View {
        ZStack {
            FormattedImages.PolaroidBG(
                innerContent: {
                    Color.black
                },
                width: 120
            )
            .rotationEffect(Angle(degrees: -30))
            
            FormattedImages.PolaroidBG(
                innerContent: {
                    if let mostRecentImage = mostRecentImage {
                        Image(uiImage: mostRecentImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        Color.black
                    }
                },
                width: 120
            )
        }
    }
}

struct AlbumView: View {
    @EnvironmentObject var sessions: SessionLoader
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedTab: AlbumTab = .month
    
    // Get current month and year
    var currentMonth: Int {
        Calendar.current.component(.month, from: Date())
    }
    
    var currentYear: Int {
        Calendar.current.component(.year, from: Date())
    }
    
    // Fetch month sessions with predicate
    @FetchRequest(
        entity: Session.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Session.started, ascending: false)],
        predicate: nil
    ) private var monthSessions: FetchedResults<Session>
    
    // Fetch year sessions with predicate
    @FetchRequest(
        entity: Session.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Session.started, ascending: false)],
        predicate: nil
    ) private var yearSessions: FetchedResults<Session>
    
    init() {
        // Set up month predicate using current month
        let monthStartDate = Calendar.current.dateInterval(of: .month, for: Date())?.start ?? Date()
        let monthEndDate = Calendar.current.dateInterval(of: .month, for: Date())?.end ?? Date()
        let monthPredicate = NSPredicate(format: "started >= %@ AND started < %@ AND imageName != nil", monthStartDate as NSDate, monthEndDate as NSDate)
        
        // Set up year predicate using current year
        let yearStartDate = Calendar.current.dateInterval(of: .year, for: Date())?.start ?? Date()
        let yearEndDate = Calendar.current.dateInterval(of: .year, for: Date())?.end ?? Date()
        let yearPredicate = NSPredicate(format: "started >= %@ AND started < %@ AND imageName != nil", yearStartDate as NSDate, yearEndDate as NSDate)
        
        print("Starting initialization...")
        
        // Initialize fetch requests with predicates
        _monthSessions = FetchRequest(
            entity: Session.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Session.started, ascending: false)],
            predicate: monthPredicate
        )
        
        _yearSessions = FetchRequest(
            entity: Session.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Session.started, ascending: false)],
            predicate: yearPredicate
        )
    }
    
    func getMonthString() -> String {
        let formatter = DateFormatter()
        return formatter.monthSymbols[currentMonth - 1]
    }
    
    func getYearString() -> String {
        return String(currentYear)
    }

    enum AlbumTab: String, CaseIterable, Identifiable {
        case month = "Month"
        case year = "Year"
        var id: String { self.rawValue }
    }

    // Get current sessions based on selected tab
    var currentSessions: [Session] {
        return selectedTab == .month ? Array(monthSessions) : Array(yearSessions)
    }

    // Get images for display (most recent first)
    func getImagesWithSessions() -> [(UIImage, Session)] {
        let ret: [(UIImage, Session)] = currentSessions.compactMap { session in
            guard let imageName = session.imageName,
                  let image = ImageLoader.loadImage(name: imageName) else { return nil }
            return (image, session)
        }
        print("getImagesWithSession() yields \(ret)")
        return ret
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
    
    func formatTimestamp(for session: Session) -> String {
        guard let started = session.started else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, HH:mm"
        return formatter.string(from: started)
    }
    
    struct ImagesGrid : View {
        var imagesWithSessions: [(UIImage, Session)]
        var removeImage: (Session) -> Void
        var formatTimestamp: (Session) -> String
        
        var body : some View {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                ForEach(Array(imagesWithSessions.enumerated()), id: \.offset) { _, item in
                    let (image, session) = item
                    ZStack(alignment: .bottomTrailing) {
                        ImageDisplay(image: image)
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .clipped()
                            .contextMenu {
                                Button(role: .destructive) {
                                    removeImage(session)
                                } label: {
                                    Label("Remove Image", systemImage: "trash")
                                }
                            }
                        
                        // Timestamp overlay
                        Text(formatTimestamp(session))
                            .font(FontTokens.architectsDaughter(size: 10))
                            .foregroundColor(.white)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(4)
                            .padding(.bottom, 4)
                            .padding(.trailing, 4)
                    }
                    .cornerRadius(8)
                }
            }
            .onAppear {
                print("OnAppear loaded")
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            // --- Month/Year Tabs ---
            HStack(spacing: 8) {
                ForEach(AlbumTab.allCases) { tab in
                    ZStack(alignment: .center) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(tab == selectedTab ? ColorTokens.red300 : ColorTokens.shade300)
                            .frame(width: 90, height: 28)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .inset(by: 1)
                                    .stroke(.white, lineWidth: 2)
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
            .padding(.bottom, 16)
            
            // --- Images Row ---
            ImagesGrid(
                imagesWithSessions: getImagesWithSessions(),
                removeImage: removeImage,
                formatTimestamp: formatTimestamp
            )
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.top, 8)
    }
}

#Preview {
    AlbumView()
        .environmentObject(SessionLoader())
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
