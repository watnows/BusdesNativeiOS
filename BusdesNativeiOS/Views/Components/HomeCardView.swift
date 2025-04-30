import SwiftUI
import CoreData

struct HomeCardView: View {
    @EnvironmentObject var viewModel: HomeViewModel
    var routeEntity: Routes
    private var routeID: NSManagedObjectID { routeEntity.objectID }
    private var busInfos: [NextBusModel] { viewModel.timeTables[routeID] ?? [] }
    private var countdownString: String { viewModel.countdowns[routeID] ?? "--:--:--" }
    private var errorMessage: NetworkError? { viewModel.errorMessages[routeID] ?? nil }

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text(routeEntity.from ?? "未設定")
                    .font(.title3)
                    .fontWeight(.medium)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Image(systemName: "arrow.right")
                    .foregroundColor(.gray)
                Text(routeEntity.to ?? "未設定")
                    .font(.title3)
                    .fontWeight(.medium)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.horizontal)

            Divider()

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
            .padding(.vertical, 5)

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
        .padding(.vertical)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(12)
        .contentShape(Rectangle())
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
        HStack{
            Spacer()
            Image(systemName: "exclamationmark.circle")
                .foregroundColor(.red)
            Text(error.displayMessage)
                .font(.footnote)
                .foregroundColor(.red)
                .multilineTextAlignment(.center)
            Text(error.localizedDescription)
            Spacer()
        }
        .padding(.vertical, 10)
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
        VStack(alignment: .leading, spacing: 6) {
            ForEach(infos.prefix(2)) { info in
                HStack(alignment: .center, spacing: 8) {
                    Text("\(info.realArrivalTime) → \(viewModel.parseTime(time: info.realArrivalTime, requiredTime: info.requiredTime))")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .frame(minWidth: 100, alignment: .leading)

                    Text("\(info.via) (\(info.busStop)番)")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                        .layoutPriority(1)

                    Spacer()

                    if info.delay != "定時運行" && !info.delay.isEmpty {
                        Text(info.delay)
                            .font(.caption)
                            .foregroundColor(.orange)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.2))
                            .clipShape(Capsule())
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
