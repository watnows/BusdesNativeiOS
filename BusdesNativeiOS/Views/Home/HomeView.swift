import SwiftUI

struct HomeView: View {
    var controller: HomeViewControllerProtocol?
    init(controller: HomeViewControllerProtocol) {
        self.controller = controller
    }

    @State var selection: Int = 1
    var body: some View {
        Button {
            controller?.goAddLine()
        } label: {
            Text("aaa")
        }
    }
}

#Preview {
    HomeView(controller: HomeViewController())
}
