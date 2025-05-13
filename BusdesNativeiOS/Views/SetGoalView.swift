import SwiftUI

struct SetGoalView: View {
    @StateObject private var viewModel: SetGoalViewModel
    @State private var selectStaition = true
    @State private var selectedGoal = "南草津駅"
    @Binding var path: NavigationPath
    @State private var showAlert = false
    @EnvironmentObject var userModel: UserService
    let receivedBusStop: BusStopModel

    init(from: BusStopModel, path: Binding<NavigationPath>) {
        self.receivedBusStop = from
        self._path = path
        _viewModel = StateObject(wrappedValue: SetGoalViewModel(from: from))
    }

    var body: some View {
        VStack {
            Spacer()
            Text("どちらでバスを降りますか？")
                .font(.headline)
            Text("乗り場：\(viewModel.from.name)")
                .font(.headline)
                .padding( .top, 50)
            HStack {
                Spacer()
                Button {
                    selectStaition = true
                    selectedGoal = "南草津駅"
                } label: {
                    Text("南草津駅")
                }
                .buttonStyle(RoundedRedButton(isSelected: selectStaition))
                .disabled(selectStaition)
                Spacer()
                Button {
                    selectStaition = false
                    selectedGoal = "立命館大学"
                } label: {
                    Text("立命館大学")
                }
                .buttonStyle(RoundedRedButton(isSelected: !selectStaition))
                .disabled(!selectStaition)
                Spacer()
            }
            .padding(.top, 50)
            Button {
                if viewModel.from.name == selectedGoal {
                    showAlert.toggle()
                    return
                } else if userModel.isRouteSaved(from: viewModel.from.name, to: selectedGoal) {
                    showAlert.toggle()
                    return
                }
                viewModel.setRoute(to: selectedGoal, userModel: userModel)
                path.removeLast(path.count)
            } label: {
                Text("決定")
            }
            .buttonStyle(RoundedGrayButton())
            .padding(.top, 40)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("設定エラー"),
                      message: Text(viewModel.from.name == selectedGoal ? "乗り場と降り場が同じようです" : "既に登録済みのルートです"),
                      dismissButton: .default(Text("OK"))
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
