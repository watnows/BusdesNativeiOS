import SwiftUI

struct BaseView: View {
    @State private var path = NavigationPath()
    @State private var selectedTab: Tab = .home
    @StateObject private var viewModel = TimeTableViewModel()
    private let appBarHeight: CGFloat = UIScreen.main.bounds.height * 0.35
    
    enum Tab {
        case home
        case timetable
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                CurvedRedBackground(height: appBarHeight)
                    .fill(Color.appRed)
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
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    CustomTabBar(selectedTab: $selectedTab)
                        .background(Color.white)
//                        .clipShape(.rect(topLeadingRadius: 75, topTrailingRadius: 75))
                }
            }
            .background(Color(uiColor: .secondarySystemBackground))
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
                case .webView(let url, let title):
                    WebView(url: url, title: title)
                }
            }
            .task {
                if viewModel.timeTableToRits == nil && viewModel.timeTableFromRits == nil {
                    await viewModel.fetchTimeTable()
                }
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        .tint(.white)
    }
}
