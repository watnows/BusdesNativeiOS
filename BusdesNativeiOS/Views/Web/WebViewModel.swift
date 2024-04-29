import SwiftUI
import WebKit

struct WebViewModel: UIViewRepresentable {
    let url: String
    var webView = WKWebView()
    var progressView = UIProgressView()
    
    func makeCoordinator() -> Cordinator {
        Cordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        webView.addSubview(progressView)
        // UIProgressViewのレイアウト設定
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.widthAnchor.constraint(equalTo: webView.widthAnchor, multiplier: 1.0).isActive = true
        progressView.topAnchor.constraint(equalTo: webView.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        progressView.leadingAnchor.constraint(equalTo: webView.leadingAnchor, constant: 0).isActive = true
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        context.coordinator.addProgressObserver()
        
        guard let url = URL(string: url) else {
            return
        }
        let request = URLRequest(url: url)
        webView.load(request)
    }
}
