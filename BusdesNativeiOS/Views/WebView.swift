import SwiftUI

struct WebView: View {
    var url: String
    var title: String
    var body: some View {
        WebViewControllerRepresentable(url: url)
            .navigationTitle(title)
            .toolbarColorScheme(.dark)
            .toolbarBackground(Color.appRed, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
    }
}

struct WebViewControllerRepresentable: UIViewControllerRepresentable {
    var url: String
    func makeUIViewController(context: Context) -> WebViewController {
        return WebViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: WebViewController, context: Context) {
    }
}
