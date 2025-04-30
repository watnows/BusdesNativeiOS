import SwiftUI

struct SetGoalView: View {
    @StateObject private var viewModel: SetGoalViewModel
    @State private var selectStaition = true
    @State private var selectedGoal = "南草津駅"
    @Binding var path: NavigationPath
    @State private var showAlert = false
    @EnvironmentObject var userModel: UserSession
    let receivedBusStop: BusStopModel

    init(from: BusStopModel, path: Binding<NavigationPath>) {
        self.receivedBusStop = from
        self._path = path
        _viewModel = StateObject(wrappedValue: SetGoalViewModel(from: from))
    }

    var body: some View {
        VStack {
            Text("どちらでバスを降りますか？")
                .font(.headline)
            Text("乗り場：\(viewModel.from.name)")
                .font(.headline)
                .padding( .top, 100)
            HStack {
                Spacer()
                Button {
                    selectStaition.toggle()
                    selectedGoal = "南草津駅"
                } label: {
                    Text("南草津駅")
                }
                .buttonStyle(RoundedRedButton(isSelected: selectStaition))
                .disabled(selectStaition)
                Spacer()
                Button {
                    selectStaition.toggle()
                    selectedGoal = "立命館大学"
                } label: {
                    Text("立命館大学")
                }
                .buttonStyle(RoundedRedButton(isSelected: !selectStaition))
                .disabled(!selectStaition)
                Spacer()
            }
            Button {
                if viewModel.from.name == selectedGoal {
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
                      message: Text("乗り場と降り場が同じようです"),
                      dismissButton: .default(Text("OK"))
                )
            }
        }
        .navigationTitle("My路線の追加")
    }
}
