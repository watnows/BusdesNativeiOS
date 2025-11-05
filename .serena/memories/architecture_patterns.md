# アーキテクチャパターン

## 目標アーキテクチャ: MVVM + Clean Architecture

### 層構成
```
Presentation → Domain ← Data
     ↑           ↑       ↑
     └─── App ──┴───────┘
```

### 各層の責務

#### Domain層 (ビジネスロジック)
- **Entities**: BusStop, Route, NextBus等のドメインモデル
- **UseCases**: GetBusStopsUseCase等のビジネスロジック実行
- **Protocols**: Repository抽象インターフェース
- **特徴**: 外部依存なしの純粋なビジネスロジック

#### Data層 (実装詳細・I/O)
- **Network**: BusAPIClient実装
- **Repositories**: Repository実装 (BusStopRepositoryImpl等)
- **DTO**: APIレスポンス用データ転送オブジェクト
- **Mappers**: DTO↔Domain変換ロジック

#### Presentation層 (UI・状態管理)
- **Views**: SwiftUI View
- **ViewModels**: @Observable + @MainActor + State構造体パターン
- **責務**: UI状態管理、UseCase呼び出し

#### App層 (依存注入)
- **依存注入**: Composition Root
- **画面ファクトリ**: 画面生成と依存関係組み立て
- **配線順序**: APIClient → Repository → UseCase → ViewModel

## 現在の構造（移行中）

### 既存ディレクトリ
- `Services/`: BusAPIService, TimerService, CountdownService等
- `Repositories/`: BusStopRepository
- `ViewModels/`: HomeViewModel, TimeTableViewModel等
- `Models/`: BusStop, NextBus, RouteModel, AppError等
- `Views/`: SwiftUI Views
- `Application/`: Constants, NavigationDestination
- `Utilities/`: Extensions, Styles, Errors

### 移行状況
- **完了**: HomeViewModel（新アーキテクチャ実装済み）
- **計画**: 他のViewModel/Serviceを順次移行予定

## ViewModelパターン

### 新アーキテクチャの標準パターン
```swift
@MainActor
@Observable
final class HomeViewModel {
    // 依存関係定義
    struct Dependency { 
        let getBusStops: () async throws -> [BusStop] 
    }
    
    // 状態管理
    struct State { 
        var busStops: [BusStop] = []
        var isLoading = false 
    }
    
    var state = State()
    private let dependency: Dependency
    
    init(dependency: Dependency) { 
        self.dependency = dependency 
    }
}
```

### 特徴
- `@MainActor`: メインスレッドでの実行保証
- `@Observable`: SwiftUIとのリアクティブバインディング
- 内部State構造体: 状態の集約管理
- Dependency注入: テスタビリティ向上
- 抽象依存: UseCase/Protocolのみに依存
