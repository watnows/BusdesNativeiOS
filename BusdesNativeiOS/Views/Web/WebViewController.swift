import UIKit
import WebKit

class WebViewController: UIViewController, WKUIDelegate {
    var webView: WKWebView!
    var progressView = UIProgressView(progressViewStyle: .bar)
    let url: String

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(url: String) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }

    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
        guard let navigationBarH = self.navigationController?.navigationBar.frame.size.height else {
            assertionFailure()
            return
        }
        progressView = UIProgressView(frame: CGRect(x: 0.0, y: navigationBarH, width: self.view.frame.size.width, height: 0.0))
        navigationController?.navigationBar.addSubview(progressView)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.isLoading), options: .new, context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let myURL = URL(string: url)
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath else {
            assertionFailure()
            return
        }

        switch keyPath {
        case #keyPath(WKWebView.isLoading):
            if webView.isLoading {
                progressView.alpha = 1.0
                progressView.setProgress(0.1, animated: true)
            } else {
                UIView.animate(
                    withDuration: 0.3,
                    animations: {
                        self.progressView.alpha = 0.0
                    },
                    completion: { _ in
                        self.progressView.setProgress(0.0, animated: false)
                    })
            }
        case #keyPath(WKWebView.estimatedProgress):
            self.progressView.setProgress(Float(webView.estimatedProgress), animated: true)
        default:
            break
        }
    }
}
