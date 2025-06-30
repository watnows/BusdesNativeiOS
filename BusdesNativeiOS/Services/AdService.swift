import Foundation
import UIKit
import GoogleMobileAds

class AdService: ObservableObject {
    static let shared = AdService()
    
    // 本番用バナー広告ユニットID（ここにあなたの本番IDを入力してください）
    private let bannerAdUnitID = "ca-app-pub-6863317449275676/4414444576" // 本番用ID
    
    @Published var isInitialized = false
    @Published var bannerAd: BannerView?
    
    private init() {}
    
    // Google広告の初期化
    func initialize() {
        MobileAds.shared.start { [weak self] status in
            DispatchQueue.main.async {
                self?.isInitialized = true
                print("Google Mobile Ads SDK initialized successfully")
            }
        }
    }
    
    // バナー広告の作成
    func createBannerAd() -> BannerView {
        let bannerView = BannerView(adSize: AdSizeBanner)
        bannerView.adUnitID = bannerAdUnitID // 本番IDを使用
        bannerView.rootViewController = UIApplication.shared.windows.first?.rootViewController
        bannerView.load(Request())
        return bannerView
    }
} 
