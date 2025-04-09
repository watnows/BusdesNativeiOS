import SwiftUI

struct MenuView: View {
    var body: some View {
        List {
            Section {
                NavigationLink(destination: WebViewControllerRepresentable(url: MenuItem.feedback.pageURL)){
                    HStack {
                        Text(MenuItem.feedback.pageName)
                            .foregroundStyle(.black)
                    }
                }
                NavigationLink(destination: WebViewControllerRepresentable(url: MenuItem.terms.pageURL)){
                    HStack {
                        Text(MenuItem.terms.pageName)
                            .foregroundStyle(.black)
                    }
                }
                NavigationLink(destination: WebViewControllerRepresentable(url: MenuItem.twitter.pageURL)){
                    HStack {
                        Text(MenuItem.twitter.pageName)
                            .foregroundStyle(.black)
                    }
                }
            } header: {
                Text("設定")
            }
            Section {
                NavigationLink(destination: WebViewControllerRepresentable(url: MenuItem.schedule.pageURL)){
                    HStack {
                        Text(MenuItem.schedule.pageName)
                            .foregroundStyle(.black)
                    }
                }
                NavigationLink(destination: WebViewControllerRepresentable(url: MenuItem.timetable.pageURL)){
                    HStack {
                        Text(MenuItem.timetable.pageName)
                            .foregroundStyle(.black)
                    }
                }
            } header: {
                Text("大学間シャトルバス")
            }
        }
    }
}
