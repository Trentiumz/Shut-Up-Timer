import SwiftUI
import CoreData

struct StatsCalendarView: View {
    @State private var currentDate = startOfDay(Date())
    @Environment(\.managedObjectContext) private var viewContext
    @State private var dayHours: [Date: TimeInterval] = [:]

    var body: some View {
        PureCalendar(dayHours: dayHours, currentDate: currentDate, showBackgroundForZeroHours: true)
            .padding(.vertical, 20)
            .onAppear {
                self.dayHours = Session.getDateHours(context: viewContext)
            }
    }
}

func startOfMonth(_ date: Date) -> Date {
    let calendar = Calendar.current
    let components = calendar.dateComponents([.year, .month], from: date)
    return calendar.date(from: components) ?? Date()
}

func startOfDay(_ date: Date) -> Date {
    let calendar = Calendar.current
    let components = calendar.dateComponents([.year, .month, .day], from: date)
    return calendar.date(from: components) ?? Date()
}

func startOfWeek(_ date: Date) -> Date {
    let calendar = Calendar.current
    let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
    if let date = calendar.date(from: components) {
        return date
    } else {
        print("Failed to get start of week for \(date)")
        return Date()
    }
}

struct StatsCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack(alignment: .top) {
            Color.black
            StatsCalendarView()
                .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                .padding()
        }
    }
}
