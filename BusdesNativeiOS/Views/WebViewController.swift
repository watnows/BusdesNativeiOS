import UIKit
import WebKit

protocol WebVIewControllerProtocol: AnyObject {
    func setProgressbar()
    func loadWebPage()
}

/// WebKitベースのWebView表示用ViewController
///
/// ## 概要
/// WKWebViewを使用してWebページを表示し、ローディングプログレスバーを提供します。
/// KVO（Key-Value Observing）により、ロード状態とプログレスを監視します。
///
/// ## 主な機能
/// - **Webページ表示**: 指定URLのWebページ読み込み
/// - **プログレス表示**: ローディング進捗をUIProgressViewで可視化
/// - **KVO監視**: isLoading/estimatedProgressを監視してUI更新
///
/// ## 使用例
/// ```swift
/// let webVC = WebViewController(url: "https://example.com")
/// navigationController?.pushViewController(webVC, animated: true)
/// ```
class WebViewController: UIViewController, WKUIDelegate {
    private var webView: WKWebView!  // loadView()で必ず初期化されるため非Optional
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
        // メモリリーク防止: ロード中のコンテンツを停止
        webView.stopLoading()

        // KVO監視の解除
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.isLoading))
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))

        // uiDelegateのnil化でretain cycleを防止
        webView.uiDelegate = nil
    }
}

extension WebViewController: WebVIewControllerProtocol {
    /// WKWebViewをセットアップ
    ///
    /// ## 処理フロー
    /// 1. WKWebViewConfiguration作成
    /// 2. WKWebView初期化
    /// 3. uiDelegateを自身に設定
    /// 4. viewプロパティに設定
    ///
    /// ## 注意
    /// - loadView()から呼ばれるため、webViewは必ず初期化される
    func setupWebView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
    }

    /// プログレスバーをセットアップ
    ///
    /// ## 処理フロー
    /// 1. progressViewをwebViewに追加
    /// 2. Auto Layoutで上部に配置
    /// 3. KVOでisLoading/estimatedProgressを監視開始
    ///
    /// ## KVO監視対象
    /// - `isLoading`: ローディング開始/終了の検知
    /// - `estimatedProgress`: 0.0〜1.0のプログレス値
    func setProgressbar() {
        webView.addSubview(progressView)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.widthAnchor.constraint(equalTo: webView.widthAnchor, multiplier: 1.0).isActive = true
        progressView.topAnchor.constraint(equalTo: webView.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        progressView.leadingAnchor.constraint(equalTo: webView.leadingAnchor, constant: 0).isActive = true
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.isLoading), options: .new, context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
    }

    /// Webページを読み込む
    ///
    /// ## パラメータ
    /// - url: 初期化時に渡されたURL文字列
    ///
    /// ## エラーケース
    /// - URL不正の場合: assertionFailure（デバッグビルドでクラッシュ）
    func loadWebPage() {
        guard let myURL = URL(string: url) else {
            assertionFailure("Invalid URL")
            return
        }
        let myRequest = URLRequest(url: myURL)
        webView.load(myRequest)
    }

    /// KVO通知を受信してUIを更新
    ///
    /// ## 監視対象
    /// - `WKWebView.isLoading`: ローディング開始/終了
    ///   - 開始時: プログレスバーを表示（alpha=1.0, progress=0.1）
    ///   - 終了時: フェードアウトアニメーション（0.3秒）
    /// - `WKWebView.estimatedProgress`: プログレス値（0.0〜1.0）
    ///   - プログレスバーの値を更新
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath else {
            assertionFailure()
            return
        }

        switch keyPath {
        case #keyPath(WKWebView.isLoading):
            if webView.isLoading {
                progressView.tintColor = .systemBlue
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
                    }
                )
            }

        case #keyPath(WKWebView.estimatedProgress):
            self.progressView.setProgress(Float(webView.estimatedProgress), animated: true)
        default:
            break
        }
    }
}
