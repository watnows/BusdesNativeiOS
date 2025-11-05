import Foundation
import UIKit
import GoogleMobileAds
import Observation
import os.log

/// 広告サービス
/// Google Mobile Ads SDKの初期化とバナー広告管理
@MainActor
@Observable
final class AdService {
    static let shared = AdService()

    // 本番用バナー広告ユニットID
    private let bannerAdUnitID = "ca-app-pub-6863317449275676/4414444576"
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.busdes", category: "AdService")

    var isInitialized = false
    var bannerAd: BannerView?

    private init() {}

    /// Google広告の初期化
    func initialize() {
        MobileAds.shared.start { [weak self] status in
            Task { @MainActor in
                self?.isInitialized = true
                self?.logger.info("Google Mobile Ads SDK initialized successfully")
            }
        }
    }

    /// バナー広告の作成
    func createBannerAd() -> BannerView {
        let bannerView = BannerView(adSize: AdSizeBanner)
        bannerView.adUnitID = bannerAdUnitID

        // iOS 15+対応: UIWindowSceneを使用してrootViewControllerを取得
        bannerView.rootViewController = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows
            .first?.rootViewController

        bannerView.load(Request())
        return bannerView
    }
} 
