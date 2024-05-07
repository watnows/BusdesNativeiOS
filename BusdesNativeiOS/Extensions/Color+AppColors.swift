import SwiftUI

extension Color {
    struct Light {
        static let red = Color(uiColor: UIColor(hex: 0xEF3124))
        static let gray = Color(uiColor: UIColor(hex: 0xD1D5D6))
    }

    struct Dark {
        static let red = Color(uiColor: UIColor(hex: 0xEF3124))
        static let gray = Color(uiColor: UIColor(hex: 0xD1D5D6))
    }

    static let appGray = Color(light: .Light.gray, dark: .Dark.gray)
    static let appRed = Color(light: .Light.red, dark: .Dark.red)
}
