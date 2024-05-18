import SwiftUI

struct TimeTableVIew: View {
    var controller: TimeTableViewControllerProtocol?

    init(controller: TimeTableViewControllerProtocol) {
        self.controller = controller
    }
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    TimeTableVIew(controller: TimeTableViewController())
}
