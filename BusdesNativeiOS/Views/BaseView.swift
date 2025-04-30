import SwiftUI

struct BaseView: View {
    @State private var path = NavigationPath()
    var body: some View {
        NavigationStack(path: $path) {
            TabView {
                HomeView(path: $path)
                    .tabItem {
                        Image(systemName: "deskclock")
                        Text("Next bus")
                    }
                TimeTableView()
                    .tabItem {
                        Image(systemName: "calendar.badge.clock")
                        Text("Time table")
                    }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Busdes!")
                        .foregroundStyle(.black)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(value: AppScreen.menu) {
                        Image(systemName: "gearshape")
                            .foregroundStyle(.black)
                    }
                }
            }
            .navigationDestination(for: AppScreen.self) { screen in
                switch screen {
                case .addLine:
                    AddLineView(path: $path)
                case .menu:
                    MenuView()
                case .webView(let url):
                    WebViewControllerRepresentable(url: url)
                }
            }
        }
    }
}
