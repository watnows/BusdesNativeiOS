import SwiftUI

struct SetGoalView: View {
    var controller: SetGoalViewControllerProtocol

    init(controller: SetGoalViewControllerProtocol) {
        self.controller = controller
    }
    @State var selectStaition = true
    @State var selectRits = false
    @State var selectedGoal = "南草津駅"
    var body: some View {
        VStack {
            Text("どちらでバスを降りますか？")
                .font(.headline)
                .padding(.top, 100)
            Text("乗り場：\(controller.from)")
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
                controller.setRoute(to: selectedGoal)
            } label: {
                Text("決定")
            }
            .buttonStyle(RoundedGrayButton())
            .padding(.top, 40)
            Button {
                controller.goHome()
            } label: {
                Text("戻る")
            }
            .buttonStyle(RoundedGrayButton())
            Spacer()
        }
        .navigationTitle("My路線の追加")
    }
}

#Preview {
    SetGoalView(controller: SetGoalViewController())
}
