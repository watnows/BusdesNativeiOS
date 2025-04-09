import SwiftUI

struct BaseView: View {
    @ObservedObject var homeViewModel: HomeViewModel
    @ObservedObject var timeTableViewModel: TimeTableViewModel
    var body: some View {
        NavigationStack {
            TabView {
                HomeView(viewModel: homeViewModel)
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
        }
    }
}
