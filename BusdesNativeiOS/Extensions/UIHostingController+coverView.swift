import SwiftUI

extension UIHostingController {
    func coverView(parent: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: parent.topAnchor),
            view.bottomAnchor.constraint(equalTo: parent.bottomAnchor),
            view.trailingAnchor.constraint(equalTo: parent.trailingAnchor),
            view.leadingAnchor.constraint(equalTo: parent.leadingAnchor)
        ])
    }
}
