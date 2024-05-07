import Foundation
import UIKit

extension UIColor {
    convenience init(hex: Int) {
        let r: CGFloat = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let g: CGFloat = CGFloat((hex & 0x00FF00) >>  8) / 255.0
        let b: CGFloat = CGFloat((hex & 0x0000FF)      ) / 255.0
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}

extension UIColor {
    convenience init(
        light lightModeColor: @escaping @autoclosure () -> UIColor,
        dark darkModeColor: @escaping @autoclosure () -> UIColor
     ) {
        self.init { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .light:
                return lightModeColor()

            case .dark:
                return darkModeColor()

            case .unspecified:
                return lightModeColor()
            @unknown default:
                return lightModeColor()
            }
        }
    }
}
