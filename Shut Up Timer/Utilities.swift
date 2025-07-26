import SwiftUI;

struct Utils {
    static func formatTime(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    static func chunked<T>(_ array: [T], size: Int = 6) -> [[T]] {
        stride(from: 0, to: array.count, by: size).map {
            Array(array[$0..<min($0 + size, array.count)])
        }
    }
}

// Helper function to convert Color to hex string
func colorToHexString(_ color: Color) -> String {
    let uiColor = UIColor(color)
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    
    uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    
    return String(format: "#%02lX%02lX%02lX",
                  lroundf(Float(red * 255)),
                  lroundf(Float(green * 255)),
                  lroundf(Float(blue * 255)))
}

func hexStringToColor(_ hex: String) -> Color {
    var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    
    if hexSanitized.hasPrefix("#") {
        hexSanitized.remove(at: hexSanitized.startIndex)
    }

    var rgb: UInt64 = 0
    Scanner(string: hexSanitized).scanHexInt64(&rgb)
    
    let r = Double((rgb & 0xFF0000) >> 16) / 255.0
    let g = Double((rgb & 0x00FF00) >> 8) / 255.0
    let b = Double(rgb & 0x0000FF) / 255.0
    
    return Color(red: r, green: g, blue: b)
}
