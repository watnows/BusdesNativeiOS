import SwiftUI

struct TimeTableView: View{
    @State private var viewModel = TimeTableViewModel()
    @State private var currentTab = 0
    @Namespace private var namespace

    private let hours = [5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24]
    private let goals = ["南草津駅→立命館大学", "立命館大学→南草津駅"]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                HStack {
                    ForEach(Array(zip(self.goals.indices, self.goals)), id: \.0, content: { index, name in
                        tabItemView(string: name, tab: index)
                    })
                }
                .frame(height: 48)
            }
            TabView(selection: $currentTab) {
                List {
                    ForEach(hours, id: \.self) { hour in
                        let timeTableInfo = viewModel.state.timeTableToRits?.timesForHour(hour) ?? []
                        if !timeTableInfo.isEmpty {
                            TimeTableParts(hour: hour, timeTableInfo: timeTableInfo)
                        }
                    }
                    .listRowBackground(Color(uiColor: .secondarySystemBackground))
                }
                .listStyle(.plain)
                .tag(0)
                .background(Color(uiColor: .secondarySystemBackground))
                List {
                    ForEach(hours, id: \.self) { hour in
                        let timeTableInfo = viewModel.state.timeTableFromRits?.timesForHour(hour) ?? []
                        if !timeTableInfo.isEmpty {
                            TimeTableParts(hour: hour, timeTableInfo: timeTableInfo)
                        }
                    }
                    .listRowBackground(Color(uiColor: .secondarySystemBackground))
                }
                .listStyle(.plain)
                .tag(1)
                .background(Color(uiColor: .secondarySystemBackground))
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }
        .task {
            if viewModel.state.timeTableToRits == nil && viewModel.state.timeTableFromRits == nil {
                await viewModel.fetchTimeTable()
            }
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
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                if self.currentTab == tab {
                    Color.white.frame(height: 3)
                        .matchedGeometryEffect(id: "underline", in: namespace, properties: .frame)
                } else {
                    Color.clear.frame(height: 3).padding(.horizontal, 15)
                }
            }
            .animation(.spring(), value: currentTab)
        }
        .buttonStyle(.plain)
    }
}

//#Preview {
//    TimeTableView(viewModel: TimeTableViewModel())
//}
