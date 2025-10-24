import SwiftUI
import SwiftData

struct HomeCardView: View {
    let viewModel: HomeViewModel
    let routeEntity: Route
    @State private var selectedInfo = 0

    private var routeID: UUID { routeEntity.id }
    private var busInfos: [NextBus] { viewModel.timeTables[routeID] ?? [] }
    private var countdownString: String { viewModel.countdowns[routeID] ?? "--:--:--" }
    private var errorMessage: NetworkError? { viewModel.errorMessages[routeID] ?? nil }
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text(routeEntity.from)
                    .font(.title2)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .minimumScaleFactor(0.5)
                Image(systemName: "arrow.right")
                    .foregroundColor(Color.appRed)
                    .font(.title)
                    .fontWeight(.heavy)
                Text(routeEntity.to)
                    .font(.title2)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .minimumScaleFactor(0.5)
            }
            .padding(.horizontal, 20)
            CustomDottedLine()
                .stroke(style: .init(dash: [4,3]))
                .foregroundStyle(Color.appGray)
                .frame(height: 0.5)
            
            Group {
                HStack {
                    Spacer()
                    Text(countdownString)
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .foregroundColor(countdownColor)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                    if shouldShowWarningIcon(for: routeEntity) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                            .padding(.leading, 2)
                    }
                    Spacer()
                }
                .padding(.top, 5)
                Group {
                    if let error = errorMessage {
                        errorView(error)
                    } else if viewModel.timeTables[routeID] == nil && errorMessage == nil {
                        loadingView
                    } else if busInfos.isEmpty {
                        emptyBusInfoView
                    } else {
                        busInfoListView(infos: busInfos)
                    }
                }
                .frame(minHeight: 40)
                .padding(.bottom, 5)
            }
        }
        .padding(.vertical)
        .background(.white)
        .clipShape(.rect(cornerRadius: 12))
        .onChange(of: viewModel.selectedBusIndices[routeID]) { oldValue, newValue in
            // ViewModelの選択インデックスがリセットされた（nilになった）場合、Viewも0に戻す
            if newValue == nil {
                selectedInfo = 0
            }
        }
        .onChange(of: busInfos.count) { oldValue, newValue in
            // バス情報の数が変わった時、選択インデックスが範囲外にならないように調整
            if selectedInfo >= newValue && newValue > 0 {
                selectedInfo = newValue - 1  // 最後のバスを選択
            }
        }
    }

    private var countdownColor: Color {
        switch countdownString {
        case "出発", "終了":
            return .gray
        case "---", "--:--:--":
            return .gray
        default:
            return .primary
        }
    }
    
    private func errorView(_ error: NetworkError) -> some View {
        VStack(spacing: 8) {
            Image(systemName: "exclamationmark.circle")
                .foregroundColor(.red)
                .font(.title2)
            Text(error.displayMessage)
                .font(.footnote)
                .foregroundColor(.red)
                .multilineTextAlignment(.center)

            // リトライ可能なエラーの場合、リトライボタンを表示
            if error.isRetryable {
                Button(action: {
                    Task {
                        await viewModel.retryFetchTimeTable(for: routeEntity)
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.clockwise")
                        Text("再試行")
                    }
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.appRed)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    private var loadingView: some View {
        ProgressView()
            .scaleEffect(0.8)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
    }
    
    
    private var emptyBusInfoView: some View {
        Text("現在接近中のバスはありません")
            .font(.footnote)
            .foregroundColor(.gray)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
    }
    
    private func busInfoListView(infos: [NextBus]) -> some View {
        VStack(alignment: .center, spacing: 6) {
            // 選択インデックスの範囲チェック（配列外アクセス防止）
            let safeIndex = min(selectedInfo, infos.count - 1)
            let currentInfo = infos[safeIndex]
            Text("\(currentInfo.via) \(currentInfo.busStop)番乗り場")
                .font(.subheadline)
                .foregroundColor(.primary)
                .padding(.bottom, 4)
            
            VStack(alignment: .leading, spacing: 10) {
                ForEach(infos.indices, id: \.self) { index in
                        Text("\(infos[index].realArrivalTime) → \(viewModel.parseTime(time: infos[index].realArrivalTime, requiredTime: infos[index].requiredTime))　　\(infos[index].via)")
                            .font(.callout)
                            .foregroundColor(selectedInfo == index ? .appRed :.primary)
                            .lineLimit(1)
                    .onTapGesture {
                        self.selectedInfo = index
                        viewModel.selectBus(at: index, for: routeID)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    private func shouldShowWarningIcon(for route: Route) -> Bool {
        return false
    }
}

//#Preview {
//    let previewRoute = Route(to: "立命館大学", from: "南草津駅")
//    let previewUserService = UserService(modelContext: ModelContext(ModelContainer(for: Route.self)))
//
//    HomeCardView(routeEntity: previewRoute)
//        .environmentObject(HomeViewModel(userModel: previewUserService))
//        .padding()
//}
