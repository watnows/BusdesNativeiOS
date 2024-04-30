import SwiftUI

struct MenuView: View {    var body: some View {
    List {
        Section {
            NavigationLink(
                destination: WebView(pageURL: MenuItem.feedback.pageURL),
                label: {
                    Text(MenuItem.feedback.pageName)
                }
            )
            NavigationLink(
                destination: WebView(pageURL: MenuItem.terms.pageURL),
                label: {
                    Text(MenuItem.terms.pageName)
                }
            )
            NavigationLink(
                destination: WebView(pageURL: MenuItem.twitter.pageURL),
                label: {
                    Text(MenuItem.twitter.pageName)
                }
            )
        } header: {
            Text("設定")
        }
        Section {
            NavigationLink(
                destination: WebView(pageURL: MenuItem.schedule.pageURL),
                label: {
                    Text(MenuItem.schedule.pageName)
                }
            )
            NavigationLink(
                destination: WebView(pageURL: MenuItem.timetable.pageURL),
                label: {
                    Text(MenuItem.timetable.pageName)
                }
            )
        } header: {
            Text("大学間シャトルバス")
        }
    }
}

}

#Preview {
    MenuView()
}
