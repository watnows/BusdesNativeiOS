# コーディング規約

## 命名規約

### Repository
- **抽象**: `BusStopRepository` (プロトコル)
- **実装**: `BusStopRepositoryImpl`

### API Client
- **抽象**: `BusAPIClient` (プロトコル)
- **実装**: `BusAPIClientImpl`

### UseCase
- **命名**: `GetBusStopsUseCase`
- **呼び出し**: `callAsFunction()` を使用

### DTO & Mapper
- **DTO**: `BusStopDTO`
- **Mapper**: `BusStopMapper`

### ViewModel
- **パターン**: `@Observable` + `@MainActor` + 内部`State`構造体
- **命名**: `HomeViewModel`, `TimeTableViewModel`等

## 依存注入パターン

### 原則
- コンストラクタ注入を使用
- ViewModelは抽象（UseCase/Protocol）のみに依存
- 具体実装には直接依存しない

### 組み立て順序
```
AppDependencies:
  APIClient → Repository → UseCase → ViewModel
```

## ファイル構成規約

### ディレクトリ構造
```
BusdesNativeiOS/
├── App/                    # エントリポイント、DI
├── Domain/                 # Entity, UseCase, Protocol
├── Data/                   # Network, Repository実装, DTO, Mapper
├── Presentation/           # View, ViewModel
│   └── Features/
│       └── Home/
│           ├── Views/
│           └── ViewModels/
├── Shared/                 # 共通UI、ユーティリティ
├── Resources/              # Assets, Localizable
└── Tests/                  # テスト
```

## Swift言語仕様

### 並行処理
- Swift 6並行処理モデルに準拠
- `async/await`を使用
- `@MainActor`で適切にスレッド管理

### エラーハンドリング
- `AppError`型を使用
- `NetworkError`でネットワークエラーを表現
- `throws`を使用したエラー伝播

### プロパティラッパー
- `@Observable`: SwiftUIバインディング
- `@MainActor`: メインスレッド実行保証
- `@Model`: SwiftDataモデル定義

## コードスタイル

### インデント
- スペース4つ

### 行の長さ
- 一般的に120文字以内を推奨

### コメント
- 日本語コメント可
- 複雑なロジックには説明コメント必須
- MARK: でセクション分割
  - `// MARK: - State`
  - `// MARK: - Dependencies`
  - `// MARK: - Public Methods`
  - `// MARK: - Private Methods`
