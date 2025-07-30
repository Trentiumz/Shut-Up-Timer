import SwiftUI
import CoreData

struct StatsCalendarView: View {
    @State private var currentDate = startOfDay(Date())
    @State private var selectedMonth = startOfMonth(Date())
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @State var dayHours: [Date: TimeInterval] = [:]
    
    private let calendar = Calendar.current
    private let daysOfWeek = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
    
    init() {
    }
    
    struct DateDateElem: Hashable {
        let date1: DateComponents
        let date2: DateComponents
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Month header with navigation
            HStack {
                Text(monthYearString)
                    .font(FontTokens.architectsDaughter(size: 24))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .foregroundColor(ColorTokens.shade100)
                
                Spacer()
                
                HStack(spacing: 8) {
                    // Up button (previous month)
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            selectedMonth = calendar.date(byAdding: .month, value: -1, to: selectedMonth) ?? selectedMonth
                        }
                    }) {
                        Image(uiImage: FormattedImages.Polygon9)
                            .resizable()
                            .frame(width: 18, height: 18)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Down button (next month) - hidden when on current month
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            selectedMonth = calendar.date(byAdding: .month, value: 1, to: selectedMonth) ?? selectedMonth
                        }
                    }) {
                        Image(uiImage: FormattedImages.Polygon10)
                            .resizable()
                            .frame(width: 18, height: 18)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(isCurrentMonth)
                }
            }
            .padding(.horizontal, 20)
            
            // Calendar grid
            VStack(spacing: 0) {
                // Days of week header
                HStack(spacing: 0) {
                    ForEach(daysOfWeek, id: \.self) { day in
                        Text(day)
                            .font(FontTokens.architectsDaughter(size: 24))
                            .lineLimit(1)
                            .minimumScaleFactor(0.3)
                            .foregroundColor(ColorTokens.shade600)
                            .padding(.horizontal, 8)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.bottom, 4)
                
                // Calendar dates grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 0) {
                    ForEach(calendarDays, id: \.self) { date in
                        DayCell(
                            date: date,
                            inCurrentMonth: isDateInCurrentMonth(date),
                            hours: dayHours[date] ?? 0,
                            isPastDate: calendar.compare(date, to: currentDate, toGranularity: .day) != .orderedDescending
                        )
                        .transition(.opacity)
                        .id(DateDateElem(date1: calendar.dateComponents([.year, .month], from: selectedMonth), date2: calendar.dateComponents([.year, .month, .day], from: date)))
                    }
                    .id(calendar.dateComponents([.year, .month], from: selectedMonth))
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(ColorTokens.brown300)
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(ColorTokens.shade100, lineWidth: 4)
                }
            )
        }
        .padding(.vertical, 20)
        .onAppear {
            self.dayHours = Session.getDateHours(context: viewContext)
        }
    }
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM, yyyy"
        return formatter.string(from: selectedMonth).uppercased()
    }
    
    private var isCurrentMonth: Bool {
        calendar.isDate(selectedMonth, equalTo: currentDate, toGranularity: .month)
    }
    
    private var calendarDays: [Date] {
        let startOfMonth = calendar.dateInterval(of: .month, for: selectedMonth)?.start ?? selectedMonth
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        
        var days: [Date] = []
        
        // Find the Sunday that starts the week containing the first day of the month
        let daysToSubtract = firstWeekday - 1 // Sunday = 1, Monday = 2, etc.
        let startDate = calendar.date(byAdding: .day, value: -daysToSubtract, to: startOfMonth) ?? startOfMonth
        
        // Add weeks until we've covered the entire month
        var currentDate = startDate
        
        while calendar.compare(currentDate, to: selectedMonth, toGranularity: .month) != .orderedDescending {
            // Add one week (7 days)
            for _ in 0..<7 {
                days.append(currentDate)
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
            }
        }
        
        return days
    }
    
    private func isDateInCurrentMonth(_ date: Date) -> Bool {
        calendar.isDate(date, equalTo: selectedMonth, toGranularity: .month)
    }
}

struct DayCell: View {
    let date: Date
    let inCurrentMonth: Bool
    let hours: TimeInterval
    let isPastDate: Bool
    
    private let calendar = Calendar.current
    
    var body: some View {
        Group {
            Text("\(calendar.component(.day, from: date))")
                .font(FontTokens.architectsDaughter(size: 18))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .foregroundColor(textColor)
                .padding(.vertical, 2)
                .frame(maxWidth: .infinity)
                .background(backgroundColor)
                .cornerRadius(10)
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 3)
    }
    
    private var textColor: Color {
        if !inCurrentMonth {
            return ColorTokens.shade400
        }
        
        if backgroundColor == .clear {
            return .black
        } else if backgroundColor == .white {
            return .black
        } else {
            return .white
        }
    }
    
    private var backgroundColor: Color {
        if !inCurrentMonth {
            return Color.clear
        }
        
        if !isPastDate {
            return Color.clear
        }
        
        // Color based on hours (0-12 hours)
        let normalizedHours = min(hours / 3600, 12) // Convert to hours and cap at 12
        let intensity = normalizedHours / 12.0 // 0.0 to 1.0
        
        if intensity == 0 {
            return .white
        } else if intensity <= 0.5 {
            // Light pinkish-red for lower hours
            return ColorTokens.red100.opacity(0.7)
        } else {
            // Darker reddish-brown for higher hours
            return ColorTokens.red300
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
