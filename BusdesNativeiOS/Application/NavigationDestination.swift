import Foundation

enum AppScreen: Hashable, Codable {
    case addLine
    case menu
    case webView(url: String)
}
