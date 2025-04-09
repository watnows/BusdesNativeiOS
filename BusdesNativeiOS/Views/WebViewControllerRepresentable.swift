import SwiftUI

struct WebViewControllerRepresentable: UIViewControllerRepresentable {
    var url: String
    func makeUIViewController(context: Context) -> WebViewController {
        return WebViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: WebViewController, context: Context) {
    }
}
