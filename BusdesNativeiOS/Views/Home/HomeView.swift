import SwiftUI

struct HomeView: View {
    var controller: HomeViewControllerProtocol?
    init(controller: HomeViewControllerProtocol) {
        self.controller = controller
    }

    @State var selection: Int = 1
    var body: some View {
        TabView(
            selection: $selection,
            content: {
                Button {
                    controller?.goAddLine()
                } label: {
                    Text("aaa")
                }
                    .tabItem {
                        Text("Next bus")
                    }
                    .tag(1)
                Text("Tab Content 2")
                    .tabItem {
                        Text( "Timetable")
                    }
                    .tag(2)
            }
        )
    }
}

#Preview {
    HomeView(controller: HomeViewController())
}
