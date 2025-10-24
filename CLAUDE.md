# CLAUDE.md

このファイルは、claude.ai/codeでこのリポジトリのコードを操作する際のガイダンスを提供します。

## 開発コマンド

### ビルド
- Xcodeでビルド: `⌘+B`
- コマンドライン: `xcodebuild -project BusdesNativeiOS.xcodeproj -scheme BusdesNativeiOS build`

### テスト実行
- Xcodeでテスト: `⌘+U`
- コマンドライン: `xcodebuild -project BusdesNativeiOS.xcodeproj -scheme BusdesNativeiOS test`

### 実行
- Xcodeで実行: `⌘+R`
- Simulatorまたは実機でアプリをビルド・実行

## アーキテクチャ概要

このプロジェクトは**MVVM + Clean Architecture**への移行中で、Domain/Data/Presentation層の3層構造を採用しています：

### 層構成と責務
- **Domain層**: ビジネスロジック（Entities/UseCases/Repository Protocols）。外部依存なしの純粋ロジック
- **Data層**: 外界とのI/O（Network/Persistence/API Client実装・Repository実装・DTO/Mapper）
- **Presentation層**: SwiftUI Views/ViewModels。UI状態管理・UseCase呼び出し
- **App層**: 依存注入（Composition Root）・画面ファクトリ

### 依存の方向
```
Presentation → Domain ← Data
     ↑           ↑       ↑
     └─── App ──┴───────┘
```

## 重要なディレクトリ構成

```
BusdesNativeiOS/
├── App/                    # アプリエントリポイント・DI組み立て
│   ├── BusdesNativeiOSApp.swift
│   ├── AppDependencies.swift
│   └── Constants.swift
├── Domain/                 # ビジネスロジック・抽象
│   ├── Entities/          # BusStop, Route, NextBus等
│   ├── UseCases/          # GetBusStopsUseCase等
│   └── Protocols/         # Repository抽象
├── Data/                  # 実装詳細・I/O
│   ├── Network/           # BusAPIClient実装
│   ├── Repositories/      # Repository実装
│   ├── DTO/               # APIレスポンス用DTO
│   └── Mappers/           # DTO↔Domain変換
├── Presentation/          # UI・状態管理
│   └── Features/
│       └── Home/
│           ├── Views/     # SwiftUI View
│           └── ViewModels/ # @Observable ViewModel
├── Shared/                # 共通UI・ユーティリティ
├── Resources/             # Assets・Localizable
└── Tests/                 # テスト各層
```

## コーディング規約

### 命名規約
- Repository抽象: `BusStopRepository`、実装: `BusStopRepositoryImpl`
- API Client抽象: `BusAPIClient`、実装: `BusAPIClientImpl`
- UseCase: `GetBusStopsUseCase`（`callAsFunction()`で呼び出し）
- DTO: `BusStopDTO`、Mapper: `BusStopMapper`
- ViewModel: `@Observable` + `@MainActor` + 内部`State`構造体

### 依存注入
- コンストラクタ注入を使用
- `AppDependencies`で`APIClient → Repository → UseCase → ViewModel`の順で組み立て
- ViewModelは抽象（UseCase/Protocol）のみに依存、具体実装には依存しない

### ViewModelパターン
```swift
@MainActor
@Observable
final class HomeViewModel {
    struct Dependency { let getBusStops: () async throws -> [BusStop] }
    struct State { var busStops: [BusStop] = []; var isLoading = false }
    var state = State()
    private let dependency: Dependency
    init(dependency: Dependency) { self.dependency = dependency }
}
```

## 開発時の注意点

### 新機能追加時
1. Domain層でEntity/UseCase/Repository抽象を定義
2. Data層でRepository実装・DTO・Mapper作成
3. Presentation層でViewModel・View作成
4. App層でDI配線追加

### テスト方針
- Domain: モックRepositoryでUseCaseをユニットテスト
- Data: URLProtocolスタブで統合テスト
- Presentation: モックUseCaseでViewModelをユニットテスト

### 既存コードとの関係
- 既存の`Services/`や`Repositories/`は段階的にClean Architectureパターンへ移行中
- `HomeViewModel`は新アーキテクチャで実装済み
- 他の機能は今後順次移行予定

詳細は`ARCHITECTURE.md`と`DIRECTORY_GUIDE.md`を参照してください。