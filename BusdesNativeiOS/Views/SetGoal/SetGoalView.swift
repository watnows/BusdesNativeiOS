import SwiftUI

struct SetGoalView: View {
    var controller: SetGoalViewControllerProtocol?

    init(controller: SetGoalViewControllerProtocol) {
        self.controller = controller
    }
    @State var selectStaition = true
    @State var selectRits = false
    var body: some View {
        VStack {
            Text("どちらでバスを降りますか？")
                .font(.headline)
                .padding(.top, 100)
            Spacer()
            HStack {
                Spacer()
                Button {
                    selectStaition.toggle()
                    selectRits.toggle()
                } label: {
                    Text("南草津駅")
                }
                .buttonStyle(RoundedRedButton(isSelected: selectStaition))
                .disabled(selectStaition)
                Spacer()
                Button {
                    selectRits.toggle()
                    selectStaition.toggle()
                } label: {
                    Text("立命館大学")
                }
                .buttonStyle(RoundedRedButton(isSelected: selectRits))
                .disabled(selectRits)
                Spacer()
            }
            Button {
                controller?.goHome()
            } label: {
                Text("決定")
            }
            .buttonStyle(RoundedGrayButton())
            .padding(.top, 40)
            Button {
                controller?.goHome()
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
