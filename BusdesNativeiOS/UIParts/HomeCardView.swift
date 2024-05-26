import SwiftUI

struct HomeCardView: View {
    @ObservedObject var viewModel: HomeCardViewModel
    @State private var selectedIndex: Int = 0

    var body: some View {
        VStack {
            HStack{
                Text(viewModel.myRoute.fr)
                    .font(.title2)
                    .padding(.leading, 30)
                Spacer()
                Text("→")
                    .font(.title)
                Spacer()
                Text(viewModel.myRoute.to)
                    .font(.title2)
                    .padding(.trailing, 30)
            }
            Text("00:00:00")
                .font(.largeTitle)
            HStack {
                Text(viewModel.bus.approachInfos[selectedIndex].via )
                Text(viewModel.bus.approachInfos[selectedIndex].busStop + "番乗り場")
            }
            ForEach(0 ..< viewModel.bus.approachInfos.count) { index in
                HStack {
                    Text(viewModel.bus.approachInfos[index].realArrivalTime)
                        .foregroundColor(selectedIndex == index ? .red : .black)
                    Text("→")
                        .foregroundColor(selectedIndex == index ? .red : .black)
                    Text(viewModel.parseTime(time: viewModel.bus.approachInfos[index].realArrivalTime, requiredTime: viewModel.bus.approachInfos[index].requiredTime))
                        .foregroundColor(selectedIndex == index ? .red : .black)
                    Text(viewModel.bus.approachInfos[index].via)
                        .foregroundColor(selectedIndex == index ? .red : .black)
                }.onTapGesture {
                    selectedIndex == index
                }
            }
        }
        .onAppear {
            viewModel.fetchTimeTable(fr: viewModel.myRoute.fr, to: viewModel.myRoute.to)
            print(viewModel.bus.approachInfos.count)
        }
    }
}
#Preview {
    HomeCardView(viewModel: HomeCardViewModel(bus: ApproachInfo(approachInfos: [NextBusModel.demo]), myRoute: MyRoute.demo, controller: HomeViewController()))
}
