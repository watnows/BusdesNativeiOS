import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    var body: some View {
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
