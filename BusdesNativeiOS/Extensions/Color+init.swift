import SwiftUI

extension Color {
    init(
        light lightModeColor: Color,
        dark darkModeColor: Color
    ) {
        self.init(UIColor(
            light: UIColor(lightModeColor),
            dark: UIColor(darkModeColor)
        ))
    }
}
