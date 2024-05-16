import SwiftUI

struct AddLineView: View {
//    var controller: AddLineViewControllerProtocol?
//
//    init(controller: AddLineViewControllerProtocol) {
//        self.controller = controller
//    }

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
                Button {
//                    controller?.tapBusStop()
                } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(busStop.kana)
                                .font(.caption)
                                .foregroundStyle(.black)
                                .multilineTextAlignment(.leading)
                            Text(busStop.name)
                                .font(.headline)
                                .foregroundStyle(.black)
                                .multilineTextAlignment(.leading)
                        }
                        .foregroundStyle(.black)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.gray)
                    }
                }
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
