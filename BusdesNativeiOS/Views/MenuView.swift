import SwiftUI

struct MenuView: View {
    var body: some View {
        List {
            Section("設定") {
                menuItemLink(for: .feedback)
                menuItemLink(for: .terms)
                menuItemLink(for: .twitter)
            }
            Section("大学間シャトルバス") {
                menuItemLink(for: .schedule)
                menuItemLink(for: .timetable)
                
            }
        }
    }
    private func menuItemLink(for item: MenuItem) -> some View {
        NavigationLink(value: AppScreen.webView(url: item.pageURL)) {
            Text(item.pageName)
                .foregroundStyle(.black)
        }
    }
}
