import SnapKit
import UIKit
import WebKit

protocol WebVIewControllerProtocol: AnyObject {
    func setProgressbar()
    func loadWebPage()
}

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
        setupWebView()
        setProgressbar()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadWebPage()
    }

    override func viewWillDisappear(_ animated: Bool) {
        progressView.removeFromSuperview()
    }

    deinit {
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.isLoading))
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
    }
}

extension WebViewController: WebVIewControllerProtocol {
    func setupWebView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
    }

    func setProgressbar() {
        navigationController?.navigationBar.addSubview(progressView)
        progressView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(2)
        }
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.isLoading), options: .new, context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
    }

    func loadWebPage() {
        guard let myURL = URL(string: url) else {
            assertionFailure("Invalid URL")
            return
        }
        let myRequest = URLRequest(url: myURL)
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
