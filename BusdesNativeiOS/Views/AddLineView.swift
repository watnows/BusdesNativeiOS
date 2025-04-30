import SwiftUI

struct AddLineView: View {
    @StateObject var viewModel = AddLineViewModel()
    @Binding var path: NavigationPath

    var body: some View {
        List {
            ForEach(viewModel.filteredData, id: \.self) { busStop in
                NavigationLink(value: busStop) {
                    VStack(alignment: .leading) {
                        Text(busStop.name)
                        Text(busStop.kana)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .searchable(text: $viewModel.searchQuery, placement: .navigationBarDrawer(displayMode: .always), prompt: "バス停名を入力")
        .onChange(of: viewModel.searchQuery) {
            viewModel.filterBusStops(with: viewModel.searchQuery)
        }
        .navigationDestination(for: BusStopModel.self) { busStop in
             SetGoalView(from: busStop, path: $path)
        }
        .navigationTitle("バス停を選択")
    }
}
