import SwiftUI

struct MenuView: View {
    var body: some View {
        NavigationStack() {
            List {
                Section {
                    NavigationLink(destination: WebView(pageURL: "https://forms.gle/wpq6MYUeWfisKDKQA")){
                        Text("フィードバックを送信")
                    }
                    NavigationLink(destination: WebView(pageURL: "https://ryota2425.github.io/")){
                        Text("利用規約")
                        
                    }
                    NavigationLink(destination: WebView(pageURL: "https://twitter.com/busdes_rits")){
                        Text("最新情報【X】")
                    }
                } header: {
                    Text("設定")
                }
                Section {
                    NavigationLink(destination: WebView(pageURL: "https://mercy34mercy.github.io/bustimer_kic/shuttle/schedule.jpg")){
                        Text("運行スケジュール")
                    }
                    NavigationLink(destination: WebView(pageURL: "https://mercy34mercy.github.io/bustimer_kic/shuttle/timetable.jpg")){
                        Text("時刻表")
                    }
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
