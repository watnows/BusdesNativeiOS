import SwiftUI
import SwiftData

struct SetGoalView: View {
    @State private var viewModel: SetGoalViewModel
    @State private var selectStation = true
    @Binding var path: NavigationPath

    // SwiftDataから既存路線を取得（重複チェック用）
    @Query private var savedRoutes: [Route]
    @Environment(\.modelContext) private var modelContext

    let receivedBusStop: BusStop

    init(from: BusStop, path: Binding<NavigationPath>) {
        self.receivedBusStop = from
        self._path = path
        self.viewModel = SetGoalViewModel(from: from)
    }

    var body: some View {
        VStack {
            Spacer()
            Text("どちらでバスを降りますか？")
                .font(.headline)
            Text("乗り場：\(viewModel.from.name)")
                .font(.headline)
                .padding(.top, 50)

            HStack {
                Spacer()
                Button {
                    selectStation = true
                    viewModel.selectGoal("南草津駅")
                } label: {
                    Text("南草津駅")
                }
                .buttonStyle(RoundedRedButton(isSelected: selectStation))
                .disabled(selectStation)

                Spacer()
                Button {
                    selectStation = false
                    viewModel.selectGoal("立命館大学")
                } label: {
                    Text("立命館大学")
                }
                .buttonStyle(RoundedRedButton(isSelected: !selectStation))
                .disabled(!selectStation)
                Spacer()
            }
            .padding(.top, 50)

            Button {
                if viewModel.setRoute(
                    to: viewModel.state.selectedGoal,
                    modelContext: modelContext,
                    existingRoutes: savedRoutes
                ) {
                    // 成功した場合、ナビゲーションをリセット
                    path.removeLast(path.count)
                }
            } label: {
                Text("決定")
            }
            .buttonStyle(RoundedGrayButton())
            .padding(.top, 40)
            .alert(isPresented: $viewModel.state.showAlert) {
                Alert(
                    title: Text("設定エラー"),
                    message: Text(viewModel.state.alertMessage),
                    dismissButton: .default(Text("OK")) {
                        viewModel.dismissAlert()
                    }
                )
            }
            Spacer()
        }
        .toolbarColorScheme(.dark)
        .navigationTitle("My路線の追加")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark)
        .toolbarBackground(Color.appRed, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

#Preview {
    NavigationView {
        SetGoalView(from: BusStop(name: "南草津駅", kana: "みなみくさつえき"), path: .constant(NavigationPath()))
            .modelContainer(for: Route.self, inMemory: true)
    }
}
