import SwiftUI

struct MenuView: View {
    @ObservedObject var viewModel: MenuViewModel
    var body: some View {
        List {
            Section {
                NavigationLink(destination: WebViewControllerRepresentable(url: MenuItem.feedback.pageURL)){
                    HStack {
                        Text(MenuItem.feedback.pageName)
                            .foregroundStyle(.black)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.gray)
                    }
                }
                NavigationLink(destination: WebViewControllerRepresentable(url: MenuItem.terms.pageURL)){
                    HStack {
                        Text(MenuItem.terms.pageName)
                            .foregroundStyle(.black)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.gray)
                    }
                }
                NavigationLink(destination: WebViewControllerRepresentable(url: MenuItem.twitter.pageURL)){
                    HStack {
                        Text(MenuItem.twitter.pageName)
                            .foregroundStyle(.black)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.gray)
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
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.gray)
                    }
                }
                NavigationLink(destination: WebViewControllerRepresentable(url: MenuItem.timetable.pageURL)){
                    HStack {
                        Text(MenuItem.timetable.pageName)
                            .foregroundStyle(.black)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.gray)
                    }
                }
            } header: {
                Text("大学間シャトルバス")
            }
        }
    }
}

