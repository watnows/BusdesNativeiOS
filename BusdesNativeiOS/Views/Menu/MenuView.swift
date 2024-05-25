import SwiftUI

struct MenuView: View {
    @ObservedObject var viewModel: MenuViewModel
    var body: some View {
        List {
            Section {
                Button {
                    
                    viewModel.goWeb(url: MenuItem.feedback.pageURL)
                } label: {
                    HStack {
                        Text(MenuItem.feedback.pageName)
                            .foregroundStyle(.black)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.gray)
                    }
                }
                Button {
                    viewModel.goWeb(url: MenuItem.terms.pageURL)
                } label: {
                    HStack {
                        Text(MenuItem.terms.pageName)
                            .foregroundStyle(.black)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.gray)
                    }
                }
                Button {
                    viewModel.goWeb(url: MenuItem.twitter.pageURL)
                } label: {
                    HStack {
                        Text(MenuItem.twitter.pageName)
                            .foregroundStyle(.black)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.gray)
                    }
                }
            } header: {
                Text("設定")
            }
            Section {
                Button {
                    viewModel.goWeb(url: MenuItem.schedule.pageURL)
                } label: {
                    HStack {
                        Text(MenuItem.schedule.pageName)
                            .foregroundStyle(.black)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.gray)
                    }
                }
                Button {
                    viewModel.goWeb(url: MenuItem.timetable.pageURL)
                } label: {
                    HStack {
                        Text(MenuItem.timetable.pageName)
                            .foregroundStyle(.black)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.gray)
                    }
                }
            } header: {
                Text("大学間シャトルバス")
            }
        }
    }
}

#Preview {
    MenuView(viewModel: MenuViewModel(controller: MenuViewController()))
}
