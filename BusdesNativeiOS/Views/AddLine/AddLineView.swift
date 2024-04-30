import SwiftUI

struct AddLineView: View {
    @State var searchText = ""
    @State var busStopList = BusStopModel.dataList
    private var filteredItem: [BusStopModel] {
        let searchResult = busStopList.filter({ $0.name.contains(searchText) || $0.kana.contains(searchText) })
        return searchText.isEmpty ? busStopList : searchResult
    }

    var body: some View {
        VStack {
            Text("どこからバスを乗りますか？")
                .font(.headline)
            List(filteredItem, id: \.self) { busStop in
                NavigationLink(destination: SetGoalView(), label: {
                    VStack(alignment: .leading) {
                        Text(busStop.kana)
                            .font(.caption)
                            .multilineTextAlignment(.leading)
                        Text(busStop.name)
                            .font(.headline)
                            .multilineTextAlignment(.leading)
                    }
                })
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .listStyle(.inset)
            .buttonStyle(.plain)
        }
        .navigationTitle("My路線の追加")
    }
}

#Preview {
    AddLineView()
}
