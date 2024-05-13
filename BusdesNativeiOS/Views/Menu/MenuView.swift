import SwiftUI

struct MenuView: View {
    var controller: MenuViewControllerProtocol?

    init(controller: MenuViewControllerProtocol) {
        self.controller = controller
    }
    var body: some View {
        List {
            Section {
                Button {
                    controller?.next(url: MenuItem.feedback.pageURL)
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
                    controller?.next(url: MenuItem.terms.pageURL)
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
                    controller?.next(url: MenuItem.twitter.pageURL)
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
                    controller?.next(url: MenuItem.schedule.pageURL)
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
                    controller?.next(url: MenuItem.timetable.pageURL)
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
    MenuView(controller: MenuViewController())
}
