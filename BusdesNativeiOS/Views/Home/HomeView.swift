import SwiftUI

enum Path: String, Hashable {
    case menu
}

struct HomeView: View {
    @State private var path = [Path]()
    @State var selection: Int = 1
    var body: some View {
        NavigationStack(path: $path) {
            TabView(
                selection: $selection,
                content: {
                    Text("Tab Content 1")
                        .tabItem {
                            Text("Next bus")
                        }.tag(1)
                    Text("Tab Content 2")
                        .tabItem {
                            Text( "Timetable")
                        }.tag(2)
                }
            )
            .navigationDestination(for: Path.self) { path in
                switch path {
                case .menu:
                    MenuView()
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        path.append(.menu)
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
