import SwiftUI

struct SetGoalView: View {
    @ObservedObject var viewmodel: SetGoalViewModel
    @State var selectStaition = true
    @State var selectRits = false
    @State var selectedGoal = "南草津駅"
    @Binding var path: NavigationPath
    var body: some View {
        VStack {
            Text("どちらでバスを降りますか？")
                .font(.headline)
                .padding(.top, 100)
            Text("乗り場：\(viewmodel.from)")
                .font(.headline)
                .padding( .top, 100)
            HStack {
                Spacer()
                Button {
                    selectStaition.toggle()
                    selectRits.toggle()
                    selectedGoal = "南草津駅"
                } label: {
                    Text("南草津駅")
                }
                .buttonStyle(RoundedRedButton(isSelected: selectStaition))
                .disabled(selectStaition)
                Spacer()
                Button {
                    selectRits.toggle()
                    selectStaition.toggle()
                    selectedGoal = "立命館大学"
                } label: {
                    Text("立命館大学")
                }
                .buttonStyle(RoundedRedButton(isSelected: selectRits))
                .disabled(selectRits)
                Spacer()
            }
            Button {
                viewmodel.setRoute(to: selectedGoal)
                path.removeLast(path.count)
            } label: {
                Text("決定")
            }
            .buttonStyle(RoundedGrayButton())
            .padding(.top, 40)
            .alert(isPresented: $viewmodel.showAlert) {
                Alert(title: Text("設定エラー"),
                      message: Text("乗り場と降り場が同じようです"),
                      dismissButton: .default(Text("OK"))
                )
            }
        }
        .navigationTitle("My路線の追加")
    }
}
