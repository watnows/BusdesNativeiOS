import SwiftUI

struct BaseView: View {
    @ObservedObject var homeViewModel: HomeViewModel
    @ObservedObject var timeTableViewModel: TimeTableViewModel
    @State private var path = NavigationPath()
    var body: some View {
        NavigationStack(path: $path) {
            TabView {
                HomeView(viewModel: homeViewModel, path: $path)
                    .tabItem {
                        Image(systemName: "deskclock")
                        Text("Next bus")
                    }
                TimeTableView(viewModel: timeTableViewModel)
                    .tabItem {
                        Image(systemName: "calendar.badge.clock")
                        Text("Time table")
                    }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Busdes!")
                        .foregroundStyle(.black)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: MenuView()) {
                        Image(systemName: "gearshape")
                            .foregroundStyle(.black)
                    }
                }
            }
            .navigationDestination(for: String.self) { value in
                if(value ==  "AddLine") {
                    AddLineView(path: $path)
                }
            }
        }
    }
}
