import SwiftUI
import UIKit
import GoogleMobileAds

struct BannerAdView: UIViewRepresentable {
    let adUnitID: String
    
    init(adUnitID: String = "ca-app-pub-3940256099942544/2934735716") {
        self.adUnitID = adUnitID
    }
    
    func makeUIView(context: Context) -> BannerView {
        let bannerView = BannerView(adSize: AdSizeBanner)
        bannerView.adUnitID = adUnitID
        bannerView.rootViewController = UIApplication.shared.windows.first?.rootViewController
        bannerView.load(Request())
        return bannerView
    }
    
    func updateUIView(_ uiView: BannerView, context: Context) {
        // 更新処理（必要に応じて）
    }
}

#Preview {
    BannerAdView()
        .frame(height: 50)
} 