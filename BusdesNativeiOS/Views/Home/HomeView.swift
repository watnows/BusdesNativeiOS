import SwiftUI

enum Path: String, Hashable {
    case menu
}

struct HomeView: View {
    var controller: HomeViewControllerProtocol?
    
    init(controller: HomeViewControllerProtocol) {
        self.controller = controller
    }

    @State private var path = [Path]()
    @State var selection: Int = 1
    var body: some View {
        TabView(
            selection: $selection,
            content: {
                NavigationLink("aaa", destination: AddLineView())
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
