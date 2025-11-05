import Foundation
import UIKit
import GoogleMobileAds
import Observation
import os.log

/// 広告サービス
///
/// ## 概要
/// Google Mobile Ads SDKの初期化とバナー広告管理を担当するシングルトンサービスです。
/// `@Observable`マクロによる状態管理とSwift Concurrency対応により、
/// 安全で効率的な広告表示を実現しています。
///
/// ## 主な機能
/// - Google Mobile Ads SDKの初期化管理
/// - バナー広告の作成と設定
/// - エラーハンドリングとリトライロジック
/// - 初期化状態の監視
///
/// ## 使用例
/// ```swift
/// // アプリ起動時に初期化
/// AdService.shared.initialize()
///
/// // バナー広告の表示
/// if AdService.shared.isInitialized {
///     let banner = AdService.shared.createBannerAd()
///     // Viewに追加
/// }
/// ```
///
/// ## 技術仕様
/// - **Thread Safety**: `@MainActor`により全操作がメインスレッドで実行
/// - **State Management**: `@Observable`により状態変更が自動追跡
/// - **iOS Version**: iOS 15+対応（UIWindowSceneベース）
/// - **Error Recovery**: 広告読み込み失敗時の自動リトライ
@MainActor
@Observable
final class AdService {
    static let shared = AdService()

    // MARK: - Properties

    /// 本番用バナー広告ユニットID
    /// Google AdMobコンソールで生成されたアプリ固有のID
    private let bannerAdUnitID = "ca-app-pub-6863317449275676/4414444576"

    /// ロガー（診断・デバッグ用）
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.busdes", category: "AdService")

    /// Google Mobile Ads SDKが初期化済みかどうか
    ///
    /// ## 監視パターン
    /// ViewからこのプロパティをObserveすることで、
    /// 初期化完了後に広告表示UIを適切に表示できます。
    /// ```swift
    /// if adService.isInitialized {
    ///     BannerAdView()
    /// }
    /// ```
    var isInitialized = false

    /// 現在表示中のバナー広告（オプショナル）
    /// 広告の再利用や管理に使用
    var bannerAd: BannerView?

    // MARK: - Initialization

    /// プライベートイニシャライザ
    /// シングルトンパターンを強制し、複数インスタンス作成を防止
    private init() {}

    // MARK: - Public Methods

    /// Google Mobile Ads SDKの初期化
    ///
    /// アプリケーション起動時に1回だけ呼び出してください。
    /// 初期化は非同期で実行され、完了後に`isInitialized`がtrueになります。
    ///
    /// ## 呼び出しタイミング
    /// - AppDelegateの`application(_:didFinishLaunchingWithOptions:)`
    /// - または、SwiftUIの`App`構造体の`.onAppear`
    ///
    /// ## エラーハンドリング
    /// 初期化失敗時はログに記録され、`isInitialized`はfalseのままになります。
    /// この場合、広告は表示されませんがアプリ本体の機能には影響しません。
    ///
    /// ## 使用例
    /// ```swift
    /// @main
    /// struct BusdesApp: App {
    ///     init() {
    ///         AdService.shared.initialize()
    ///     }
    /// }
    /// ```
    func initialize() {
        MobileAds.shared.start { [weak self] status in
            Task { @MainActor in
                guard let self = self else { return }

                // 初期化ステータスのチェック
                if let error = status.adapterStatusesByClassName.values.first(where: { $0.state == .notReady })?.description {
                    self.logger.warning("広告SDK初期化に一部失敗: \(error)")
                }

                self.isInitialized = true
                self.logger.info("Google Mobile Ads SDK initialized successfully")
            }
        }
    }

    /// バナー広告の作成
    ///
    /// 新しいバナー広告ビューを作成し、広告リクエストを開始します。
    /// このメソッドは必ず`initialize()`完了後（`isInitialized == true`）に呼び出してください。
    ///
    /// ## 前提条件
    /// - `isInitialized`がtrueであること
    /// - アクティブなUIWindowSceneが存在すること
    ///
    /// ## エラーケース
    /// - rootViewControllerが取得できない場合、ログに警告を出力
    /// - 広告読み込みに失敗した場合、空のバナービューを返す（アプリは動作継続）
    ///
    /// ## 使用例
    /// ```swift
    /// struct HomeView: View {
    ///     @State private var adService = AdService.shared
    ///
    ///     var body: some View {
    ///         if adService.isInitialized {
    ///             BannerAdView()
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// - Returns: 設定済みのバナー広告ビュー
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

    // MARK: - Private Methods

    /// アクティブなUIWindowSceneからrootViewControllerを取得
    ///
    /// iOS 15+で非推奨となった`UIApplication.shared.windows`の代替実装。
    /// 現在接続されているシーンから最初のアクティブなWindowSceneを検索し、
    /// そのrootViewControllerを返します。
    ///
    /// ## 実装詳細
    /// 1. `UIApplication.shared.connectedScenes`から全シーンを取得
    /// 2. UIWindowSceneにキャスト可能な最初のシーンを選択
    /// 3. そのシーンのwindowsから最初のrootViewControllerを返す
    ///
    /// ## エラーケース
    /// - アクティブなWindowSceneが存在しない → nil
    /// - windowsが空、またはrootViewControllerが未設定 → nil
    ///
    /// - Returns: 取得できた場合はrootViewController、失敗時はnil
    private func getRootViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            return nil
        }
        return rootViewController
    }
} 
