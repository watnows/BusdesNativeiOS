import SwiftUI

struct SetGoalView: View {
    @State var selected = 0
    var body: some View {
        VStack {
            Text("どちらでバスを降りますか？")
                .font(.headline)
                .padding(.top, 100)
            Spacer()
            HStack {
                Spacer()
                Button {
                    selected = 0
                } label: {
                    Text("南草津駅")
                }
                .frame(width: 130, height: 40)
                .foregroundColor(.white)
                .background(.red) // EF3124
                .clipShape(Capsule())
                Spacer()
                Button {
                    selected = 1
                } label: {
                    Text("立命館大学")
                }
                .frame(width: 130, height: 40)
                .foregroundColor(.white)
                .background(.red)
                .clipShape(Capsule())
                 Spacer()
            }
            .padding(.bottom, 40)
            Button {
                MenuView()
            } label: {
                Text("決定")
            }
            .frame(width: 130,height:40)
            .foregroundColor(.black)
            .background(.gray)
            .clipShape(Capsule())
            Button {
                MenuView()
            } label: {
                Text("戻る")
            }
            .frame(width: 130, height: 40)
            .foregroundColor(.black)
            .background(.gray)
            .clipShape(Capsule())
            Spacer()
        }
        .navigationTitle("My路線の追加")
    }
}

#Preview {
    SetGoalView()
}
