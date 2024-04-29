import SwiftUI

struct MenuView: View {
    @State private var path = [MenuItems]()
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("フィードバックを送信")
                    Text("利用規約")
                    Text("最新情報【X】")
                } header: {
                    Text("設定")
                }
                Section {
                    Text("運行スケジュール")
                    Text("時刻表")
                } header: {
                    Text("大学間シャトルバス")
                }
            }
        }
    }
}

#Preview {
    MenuView()
}
