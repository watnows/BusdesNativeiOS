# ディレクトリ構造詳細

## 現在の実際の構造

```
BusdesNativeiOS/
├── App/
│   └── BusdesNativeiOSApp.swift        # アプリエントリポイント、SwiftData設定、広告初期化
│
├── ViewModels/
│   ├── HomeViewModel.swift             # ホーム画面の状態管理（新アーキテクチャ実装済み）
│   ├── TimeTableViewModel.swift        # 時刻表画面
│   ├── SetGoalViewModel.swift          # 目標設定
│   └── AddLineViewModel.swift          # ルート追加
│
├── Views/
│   ├── BaseView.swift                  # メインエントリビュー
│   ├── HomeView.swift                  # ホーム画面UI
│   ├── TimeTableView.swift             # 時刻表UI
│   ├── SetGoalView.swift               # 目標設定UI
│   ├── AddLineView.swift               # ルート追加UI
│   ├── MenuView.swift                  # メニューUI
│   ├── WebView.swift                   # WebViewラッパー
│   ├── WebViewController.swift         # WebViewコントローラ
│   └── Components/                     # 再利用可能コンポーネント
│       ├── HomeCardView.swift          # ホームカード
│       ├── TimeTableParts.swift        # 時刻表パーツ
│       └── BannerAdView.swift          # バナー広告
│
├── Models/
│   ├── BusStop.swift                   # バス停エンティティ
│   ├── NextBus.swift                   # 次のバス情報
│   ├── RouteModel.swift                # ルートモデル（SwiftData @Model）
│   ├── TimeTableModel.swift            # 時刻表モデル
│   ├── ApproachInfoModel.swift         # 接近情報
│   ├── AppError.swift                  # アプリケーションエラー定義
│   └── LoadingState.swift              # ローディング状態
│
├── Services/
│   ├── BusAPIService.swift             # バスAPI通信サービス
│   ├── TimerService.swift              # タイマー管理
│   ├── CountdownService.swift          # カウントダウン管理
│   ├── APICacheService.swift           # APIキャッシュ管理
│   └── AdService.swift                 # 広告サービス
│
├── Repositories/
│   └── BusStopRepository.swift         # バス停データリポジトリ（JSON読み込み）
│
├── Application/
│   ├── Constants.swift                 # アプリ定数（API URL、外部リンク）
│   └── NavigationDestination.swift     # ナビゲーション先定義
│
├── Utilities/
│   ├── AdHelper.swift                  # 広告ヘルパー
│   ├── MenuItem.swift                  # メニュー項目定義
│   ├── Extensions/
│   │   └── Color.swift                 # Colorエクステンション
│   ├── Styles/
│   │   ├── BackGroundStyle.swift       # 背景スタイル
│   │   ├── ButtonStyle.swift           # ボタンスタイル
│   │   ├── CustomDottedLine.swift      # 点線スタイル
│   │   ├── CustomTabBar.swift          # タブバースタイル
│   │   └── TabBarButton.swift          # タブボタン
│   └── Errors/
│       └── NetworkError.swift          # ネットワークエラー定義
│
├── Resources/
│   └── bus_stops.json                  # バス停データ
│
└── Assets.xcassets/
    ├── AccentColor.colorset
    ├── AppIcon.appiconset
    ├── AppGray.colorset
    └── AppRed.colorset
```

## Clean Architecture移行計画のディレクトリ（未実装）

CLAUDE.mdに記載されている将来の理想構造:

```
BusdesNativeiOS/
├── Domain/                     # 🔴 未実装
│   ├── Entities/
│   ├── UseCases/
│   └── Protocols/
│
├── Data/                       # 🔴 未実装
│   ├── Network/
│   ├── Repositories/
│   ├── DTO/
│   └── Mappers/
│
└── Presentation/               # 🟡 一部実装（HomeViewModelのみ新パターン）
    └── Features/
        └── Home/
            ├── Views/
            └── ViewModels/
```

## 移行状況サマリー

### ✅ 実装済み
- 従来のMVVMパターン（Services/ViewModels/Views）
- SwiftDataによるルート永続化
- APIキャッシング機能
- アクセシビリティ対応
- 広告統合

### 🟡 移行中
- HomeViewModel: 新アーキテクチャパターン実装済み
- 他のViewModelは従来パターン

### 🔴 未実装
- Domain層（Entities/UseCases/Repository Protocols）
- Data層（DTOとMapper）
- Presentation層のFeature分割構造
- 依存注入コンテナ（AppDependencies）

## 主要ファイルの役割

### エントリポイント
- `BusdesNativeiOSApp.swift`: @main、SwiftDataコンテナ設定、広告初期化

### データフロー
```
View → ViewModel → Service → API
                      ↓
                  Repository (ローカルデータ)
```

### 永続化
- SwiftData: `Route`モデル（お気に入りルート）
- JSON: `bus_stops.json`（バス停マスターデータ）
- キャッシュ: `APICacheService`（API応答キャッシュ）

### 外部連携
- API: `https://busdesrits.com/bus`
- Google AdMob: 広告表示
