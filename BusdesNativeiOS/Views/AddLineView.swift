import SwiftUI

struct AddLineView: View {
    @ObservedObject var viewModel = AddLineViewModel(busStops: BusStopModel.dataList)
    var body: some View {
        List {
            ForEach(viewModel.filteredData, id: \.self) { busStop in
                NavigationLink(busStop.name){
                    SetGoalView(viewmodel: SetGoalViewModel())
                }
            }
        }
        .searchable(text: $viewModel.searchQuery)
        .onChange(of: viewModel.searchQuery) {
            viewModel.filterBusStops(with: viewModel.searchQuery)
        }
    }
}
