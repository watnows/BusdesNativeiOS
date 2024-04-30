import SwiftUI
import UIKit
import WebKit

extension WebViewModel {
    class Cordinator: NSObject {
        var parent: WebViewModel
        init(parent: WebViewModel) {
            self.parent = parent
        }
        
        func addProgressObserver() {
            parent.webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), context: nil)
        }
        
        override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
            // progressViewのアニメーション処理
            if keyPath == "estimatedProgress" {
                parent.progressView.alpha = 1.0
                parent.progressView.setProgress(Float(parent.webView.estimatedProgress), animated: true)
                
                if parent.webView.estimatedProgress >= 1.0 {
                    UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveEaseOut], animations: { [weak self] in
                        self?.parent.progressView.alpha = 0.0
                    }, completion: { (finished: Bool) in
                        self.parent.progressView.setProgress(0.0, animated: false)
                    })
                }
            }
        }
    }
}
