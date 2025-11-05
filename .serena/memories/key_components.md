# 主要コンポーネント詳細

## アプリケーションエントリ

### BusdesNativeiOSApp
**ファイル**: `BusdesNativeiOS/App/BusdesNativeiOSApp.swift`
- **役割**: アプリケーションエントリポイント
- **責務**:
  - SwiftDataコンテナの初期化（Routeモデル）
  - スキーマ変更時の既存DB削除とリカバリ
  - AdServiceの初期化（シングルトン）
  - BaseViewの表示

## ViewModels（状態管理）

### HomeViewModel ⭐ 新アーキテクチャ
**ファイル**: `BusdesNativeiOS/ViewModels/HomeViewModel.swift`
- **パターン**: @Observable + @MainActor + State構造体
- **責務**:
  - リアルタイムバス情報の取得・更新
  - カウントダウンタイマー管理
  - エラーハンドリング
  - バス選択状態管理
- **依存**: BusAPIServiceProtocol（抽象に依存）
- **状態**:
  - timeTables: 時刻表データ
  - countdowns: カウントダウン状態
  - selectedBusIndices: 選択中のバス
  - errorMessages: エラーメッセージ

### TimeTableViewModel
**ファイル**: `BusdesNativeiOS/ViewModels/TimeTableViewModel.swift`
- **役割**: 時刻表画面の状態管理
- **従来パターン**: 順次移行予定

### SetGoalViewModel / AddLineViewModel
- **役割**: ルート設定・追加機能
- **従来パターン**: 順次移行予定

## Services（ビジネスロジック・API連携）

### BusAPIService
**ファイル**: `BusdesNativeiOS/Services/BusAPIService.swift`
- **プロトコル**: BusAPIServiceProtocol
- **責務**:
  - 次のバス情報取得: `fetchNextBus(from:to:)`
  - 時刻表情報取得: `fetchTimeTable(from:to:)`
  - リトライ処理（最大3回）
  - APIキャッシュ統合
- **エラー処理**: NetworkError型でエラー分類
- **並行処理**: nonisolated init、async/await

### TimerService
**ファイル**: `BusdesNativeiOS/Services/TimerService.swift`
- **役割**: 定期的な更新タイマー管理
- **責務**: APIの定期ポーリング

### CountdownService
**ファイル**: `BusdesNativeiOS/Services/CountdownService.swift`
- **役割**: バス到着までのカウントダウン計算
- **責務**: 時刻からカウントダウン秒数算出

### APICacheService
**ファイル**: `BusdesNativeiOS/Services/APICacheService.swift`
- **役割**: API応答のキャッシュ管理
- **責務**: キャッシュの保存・取得・有効期限管理

### AdService
**ファイル**: `BusdesNativeiOS/Services/AdService.swift`
- **役割**: Google AdMob広告管理
- **パターン**: シングルトン
- **責務**: 広告の初期化・表示

## Models（データモデル）

### BusStop
**ファイル**: `BusdesNativeiOS/Models/BusStop.swift`
- **役割**: バス停エンティティ
- **プロパティ**: name（停留所名）
- **準拠**: Codable, Identifiable

### RouteModel
**ファイル**: `BusdesNativeiOS/Models/RouteModel.swift`
- **役割**: お気に入りルート
- **プロトコル**: @Model（SwiftData）
- **プロパティ**: from, to, requiredTime
- **永続化**: SwiftDataによる自動永続化

### NextBus
**ファイル**: `BusdesNativeiOS/Models/NextBus.swift`
- **役割**: 次のバス情報
- **プロパティ**: 出発時刻、到着時刻等

### TimeTableModel
**ファイル**: `BusdesNativeiOS/Models/TimeTableModel.swift`
- **役割**: 時刻表データ
- **プロパティ**: 時刻表の配列

### AppError / NetworkError
**ファイル**: 
- `BusdesNativeiOS/Models/AppError.swift`
- `BusdesNativeiOS/Utilities/Errors/NetworkError.swift`
- **役割**: エラー型定義
- **準拠**: Error, LocalizedError

## Repositories（データアクセス）

### BusStopRepository
**ファイル**: `BusdesNativeiOS/Repositories/BusStopRepository.swift`
- **役割**: バス停マスターデータアクセス
- **データソース**: `Resources/bus_stops.json`
- **責務**: JSONからバス停一覧を読み込み

## Views（UI）

### BaseView
**ファイル**: `BusdesNativeiOS/Views/BaseView.swift`
- **役割**: メインエントリビュー
- **責務**: タブナビゲーション管理

### HomeView
**ファイル**: `BusdesNativeiOS/Views/HomeView.swift`
- **役割**: ホーム画面UI
- **ViewModel**: HomeViewModel
- **表示**: お気に入りルート、リアルタイムバス情報

### Components
**ディレクトリ**: `BusdesNativeiOS/Views/Components/`
- **HomeCardView**: カード型UI
- **TimeTableParts**: 時刻表部品
- **BannerAdView**: 広告バナー

## Application（設定・定数）

### Constants
**ファイル**: `BusdesNativeiOS/Application/Constants.swift`
- **API定数**:
  - baseURL: `https://busdesrits.com/bus`
  - nextBusEndpoint: `/time/v3`
  - timeTableEndpoint: `/timetable`
- **外部リンク**:
  - フィードバックフォーム
  - 利用規約
  - Twitter
  - 時刻表画像

### NavigationDestination
**ファイル**: `BusdesNativeiOS/Application/NavigationDestination.swift`
- **役割**: ナビゲーション先定義
- **責務**: 画面遷移の型安全性確保

## 依存関係図

```
View → ViewModel → Service → API
         ↓           ↓
      Model      Repository
                     ↓
                 JSON/SwiftData
```

## 並行処理・スレッド管理

### 主要な並行処理パターン
- **@MainActor**: ViewModel（UI更新保証）
- **async/await**: 非同期API呼び出し
- **nonisolated init**: サービスの初期化
- **Swift 6並行処理モデル**: 準拠済み

## キャッシング戦略

### APICacheService
- **キャッシュキー**: URL文字列
- **有効期限**: 設定可能
- **目的**: API呼び出しの削減、パフォーマンス向上
