import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    var body: some View {
        ZStack {
            if !viewModel.myRouteList.isEmpty {
                ForEach(0 ..< viewModel.myRouteList.count, id: \.self) { index in
                    HomeCardView(viewModel: viewModel, myRoute: MyRoute(fr: viewModel.myRouteList[index].fr, to: viewModel.myRouteList[index].to))
                        .onAppear{
                            Task {
                                viewModel.fetchTimeTable(fr: viewModel.myRouteList[index].fr, to: viewModel.myRouteList[index].to)
                            }
                        }
                }
            } else {
                Text("路線を追加してください")
            }
            Button {
                viewModel.goAddLine()
            } label: {
                Text("+")
            }
        }
    }
}

#Preview {
    HomeView(viewModel: HomeViewModel(bus: ApproachInfo(approachInfos: [NextBusModel.demo]), myRouteList: [MyRoute.demo], controller: HomeViewController()))
}
