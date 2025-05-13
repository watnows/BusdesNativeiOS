import SwiftUI
import CoreData

struct HomeCardView: View {
    @EnvironmentObject var viewModel: HomeViewModel
    @State private var selectedInfo = 0
    var routeEntity: Routes
    private var routeID: NSManagedObjectID { routeEntity.objectID }
    private var busInfos: [NextBusModel] { viewModel.timeTables[routeID] ?? [] }
    private var countdownString: String { viewModel.countdowns[routeID] ?? "--:--:--" }
    private var errorMessage: NetworkError? { viewModel.errorMessages[routeID] ?? nil }
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text(routeEntity.from ?? "未設定")
                    .font(.title2)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .minimumScaleFactor(0.5)
                Image(systemName: "arrow.right")
                    .foregroundColor(Color.appRed)
                    .font(.title)
                    .fontWeight(.heavy)
                Text(routeEntity.to ?? "未設定")
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
        VStack{
            Image(systemName: "exclamationmark.circle")
                .foregroundColor(.red)
            Text(error.displayMessage)
                .font(.footnote)
                .foregroundColor(.red)
                .multilineTextAlignment(.center)
        }
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
    
    private func busInfoListView(infos: [NextBusModel]) -> some View {
        VStack(alignment: .center, spacing: 6) {
            let currentInfo = infos[selectedInfo]
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
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    private func shouldShowWarningIcon(for route: Routes) -> Bool {
        return false
    }
}
