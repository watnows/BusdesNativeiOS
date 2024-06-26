import SwiftUI

struct TimeTableView: View{
    @ObservedObject var viewModel: TimeTableViewModel
    @State var currentTab = 0
    @Namespace var namespace
    let hours = [ 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24]
    let goals = ["南草津駅→立命館大学", "立命館大学→南草津駅"]
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                HStack {
                    ForEach(Array(zip(self.goals.indices, self.goals)), id: \.0, content: { index, name in
                        tabItemView(string: name, tab: index)
                    })
                }
                .background(.white)
                .frame(height: 48)
            }
            TabView(selection: $currentTab) {
                List {
                    ForEach(hours, id: \.self) { hour in
                        let timeTableInfo = viewModel.timeTableToRits?.timesForHour(hour) ?? []
                        if !timeTableInfo.isEmpty {
                            TimeTableParts(hour: hour, timeTableInfo: timeTableInfo)
                        }
                    }
                }
                .listStyle(.plain)
                .ignoresSafeArea()
                .tag(0)
                List {
                    ForEach(hours, id: \.self) { hour in
                        let timeTableInfo = viewModel.timeTableFromRits?.timesForHour(hour) ?? []
                        if !timeTableInfo.isEmpty {
                            TimeTableParts(hour: hour, timeTableInfo: timeTableInfo)
                        }
                    }
                }
                .listStyle(.plain)
                .ignoresSafeArea()
                .tag(1)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }
    }
}

extension TimeTableView {
    func tabItemView(string: String, tab: Int) -> some View {
        Button {
            self.currentTab = tab
        } label: {
            VStack {
                Spacer()
                Text(string)
                    .foregroundColor(self.currentTab == tab ? .yellow : .black)
                if self.currentTab == tab {
                    Color.yellow.frame(height: 3)
                        .matchedGeometryEffect(id: "underline", in: namespace, properties: .frame)
                } else {
                    Color.clear.frame(height: 3).padding(.horizontal, 15)
                }
            }.animation(.spring(), value: currentTab)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    TimeTableView(viewModel: TimeTableViewModel(controller: TimeTableViewController()))
}
