import SwiftUI
import CoreData

struct HomeCardView: View {
    @EnvironmentObject var viewModel: HomeViewModel
    var routeEntity: Routes
    private var routeID: NSManagedObjectID { routeEntity.objectID }
    private var busInfos: [NextBusModel]? { viewModel.timeTables[routeID] }
    private var countdownString: String { viewModel.countdowns[routeID] ?? "--:--:--" }
    private var errorMessage: NetworkError? { viewModel.errorMessages[routeID] ?? nil }
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text(routeEntity.from ?? "未設定")
                    .font(.title3)
                    .fontWeight(.medium)
                    .lineLimit(1)
                Spacer()
                Image(systemName: "arrow.right")
                    .foregroundColor(.gray)
                Spacer()
                Text(routeEntity.to ?? "未設定")
                    .font(.title3)
                    .fontWeight(.medium)
                    .lineLimit(1)
            }
            .padding(.horizontal)
            Divider()
            HStack {
                Spacer()
                Text(countdownString)
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundColor(countdownString == "出発" || countdownString == "終了" ? .gray : .primary)
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
                    HStack{
                        Spacer()
                        Image(systemName: "exclamationmark.circle")
                            .foregroundColor(.red)
                        Text(error.displayMessage)
                            .font(.footnote)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                    .padding(.vertical, 10)
                } else if let infos = busInfos {
                    if infos.isEmpty {
                        Text("現在接近中のバスはありません")
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .padding(.vertical, 10)
                    } else {
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(infos.prefix(2)) { info in
                                HStack(alignment: .center) {
                                    Text("\(info.realArrivalTime) → \(viewModel.parseTime(time: info.realArrivalTime, requiredTime: info.requiredTime))")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .frame(width: 100, alignment: .leading)
                                    Text("\(info.via) (\(info.busStop)番)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .lineLimit(1)
                                    Spacer()
                                    if info.delay != "定時運行" && !info.delay.isEmpty {
                                        Text(info.delay)
                                            .font(.caption)
                                            .foregroundColor(.orange)
                                            .padding(.horizontal, 4)
                                            .background(Color.orange.opacity(0.2))
                                            .cornerRadius(4)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                } else {
                    ProgressView()
                        .scaleEffect(0.8)
                        .padding(.vertical, 10)
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
    
    private func shouldShowWarningIcon(for route: Routes) -> Bool {
        return false
    }
}
