import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    var body: some View {
        ZStack {
            if !viewModel.myRouteList.isEmpty {
                ForEach(0 ..< viewModel.myRouteList.count, id: \.self) { index in
                    HomeCardView(viewModel: viewModel, myRoute: MyRoute(from: viewModel.myRouteList[index].from, to: viewModel.myRouteList[index].to))
                        .onAppear{
                            Task {
                                viewModel.fetchTimeTable(fr: viewModel.myRouteList[index].from, to: viewModel.myRouteList[index].to)
                            }
                        }
                }
            } else {
                Text("路線を追加してください")
            }
            NavigationLink("+") {
                AddLineView()
            }
        }
    }
}
