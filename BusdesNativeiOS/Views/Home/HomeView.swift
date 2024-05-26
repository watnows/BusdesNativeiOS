import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    var body: some View {
        HomeCardView(viewModel: HomeCardViewModel(bus: ApproachInfo(approachInfos: [NextBusModel.demo]), myRoute: MyRoute.demo, controller: HomeViewController()))
        Button {
            viewModel.goAddLine()
        } label: {
            Text("aaa")
        }
    }
}

#Preview {
    HomeView(viewModel: HomeViewModel(controller: HomeViewController()))
}
