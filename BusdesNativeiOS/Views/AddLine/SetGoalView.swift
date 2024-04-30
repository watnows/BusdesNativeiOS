import SwiftUI

struct SetGoalView: View {
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
                .buttonStyle(RoundedButton(isSelected: selectStaition))
                .disabled(selectStaition)
                Spacer()
                Button {
                    selectRits.toggle()
                    selectStaition.toggle()
                } label: {
                    Text("立命館大学")
                }
                .buttonStyle(RoundedButton(isSelected: selectRits))
                .disabled(selectRits)
                Spacer()
            }
            Button {
                MenuView()
            } label: {
                Text("決定")
            }
            .frame(width: 130,height:40)
            .foregroundColor(.black)
            .background(Color.appGray)
            .clipShape(Capsule())
            .padding(.top, 40)
            Button {
                MenuView()
            } label: {
                Text("戻る")
            }
            .frame(width: 130, height: 40)
            .foregroundColor(.black)
            .background(Color.appGray)
            .clipShape(Capsule())
            Spacer()
        }
        .navigationTitle("My路線の追加")
    }
}

#Preview {
    SetGoalView()
}
