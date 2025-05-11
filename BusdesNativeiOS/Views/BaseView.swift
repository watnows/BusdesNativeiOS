import SwiftUI

struct BaseView: View {
    @State private var path = NavigationPath()
    @State private var selectedTab: Tab = .home
    @StateObject private var viewModel = TimeTableViewModel()
    
    enum Tab {
        case home
        case timetable
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                Color.appRed
                    .ignoresSafeArea()
                VStack(spacing: 0) {
                    Group {
                        switch selectedTab {
                        case .home:
                            HomeView(path: $path)
                        case .timetable:
                            TimeTableView(viewModel: viewModel)
                        }
                    }
                    .frame(maxHeight: .infinity)
                    CustomTabBar(selectedTab: $selectedTab)
                }
            }
            .toolbarColorScheme(.dark)
            .toolbarBackground(Color.appRed, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Busdes!")
                        .foregroundStyle(.white)
                        .font(.headline)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(value: AppScreen.menu) {
                        Image(systemName: "gearshape")
                            .foregroundStyle(.white)
                            .fontWeight(.heavy)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
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
            .task {
                if viewModel.timeTableToRits == nil && viewModel.timeTableFromRits == nil {
                    await viewModel.fetchTimeTable()
                }
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
    }
}
