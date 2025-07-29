import SwiftUI

extension Goal {
    var realColor: Color? {
        if let gColor = self.color {
            return hexStringToColor(gColor)
        }
        return nil
    }
}
