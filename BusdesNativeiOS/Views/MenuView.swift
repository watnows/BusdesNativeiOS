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
        .toolbarColorScheme(.dark)
        .toolbarBackground(Color.appRed, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .navigationTitle("設定")
    }
    private func menuItemLink(for item: MenuItem) -> some View {
        NavigationLink(value: AppScreen.webView(url: item.pageURL, title: item.pageName)) {
            Text(item.pageName)
                .foregroundStyle(.black)
        }
    }
}
