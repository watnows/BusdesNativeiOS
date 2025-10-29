# お気に入りルート機能 - 要件定義書

作成日: 2025-10-26
ステータス: 要件確定 → 実装待ち
優先度: 中

---

## 📋 機能概要

ユーザーがよく使うルートをお気に入り登録し、ホーム画面の一覧上部に固定表示する機能。

### 解決する課題
- ルート数が増えた際に、頻繁に使うルートを素早く見つけられるようにする
- 毎日使うルートと時々使うルートを暗黙的に区別できるようにする

---

## ✅ 確定要件

### 1. UI/UX仕様

#### 1.1 お気に入り登録
- **トリガー**: ルートカード上のスターアイコンをタップ
- **動作**: トグル式（タップでON/OFF切り替え）
- **視覚フィードバック**:
  - 未登録: 白抜きスターアイコン（☆）
  - 登録済み: 塗りつぶしスターアイコン（★）+ 色付き（推奨: appRed or 黄色）

#### 1.2 表示順序
**優先順位:**
1. お気に入りルート（お気に入り登録順：古い→新しい）
2. 通常ルート（作成日時降順：新しい→古い）

**視覚的区別:**
- セクションヘッダーなし
- 背景色の変更なし
- 区切り線なし
- お気に入りが上部にあるだけ（シンプルな実装）

#### 1.3 解除方法
- スターアイコンを再度タップで解除
- 解除すると通常ルートの位置に移動（作成日時に応じた位置）

---

## 🏗️ 技術実装プラン

### フェーズ1: データモデル拡張（必須）

#### 1.1 RouteModel.swiftの変更

**追加プロパティ:**
```swift
@Model
final class Route {
    @Attribute(.unique) var id: UUID
    var to: String
    var from: String
    var createdAt: Date

    // 🆕 お気に入り機能
    var isFavorite: Bool = false
    var favoritedAt: Date? = nil  // お気に入り登録日時（並び替え用）

    init(to: String, from: String, createdAt: Date = Date()) {
        self.id = UUID()
        self.to = to
        self.from = from
        self.createdAt = createdAt
        self.isFavorite = false
        self.favoritedAt = nil
    }
}
```

**変更の影響:**
- ✅ SwiftDataのマイグレーションが自動実行される
- ✅ 既存データに`isFavorite = false`, `favoritedAt = nil`が自動設定される
- ⚠️ テストデータは再生成が必要になる可能性あり

---

### フェーズ2: HomeViewの変更（表示ロジック）

#### 2.1 クエリ戦略

**オプションA: 単一クエリ + Swift側ソート（推奨）**

```swift
@Query private var allRoutes: [Route]

var sortedRoutes: [Route] {
    let favorites = allRoutes
        .filter { $0.isFavorite }
        .sorted { ($0.favoritedAt ?? .distantPast) < ($1.favoritedAt ?? .distantPast) }

    let normals = allRoutes
        .filter { !$0.isFavorite }
        .sorted { $0.createdAt > $1.createdAt }

    return favorites + normals
}
```

**利点:**
- シンプルな実装
- SwiftDataのクエリを複雑にしない
- パフォーマンス: ルート数が50件以下なら問題なし

**オプションB: 複数クエリ（スケーラビリティ重視）**

```swift
@Query(filter: #Predicate<Route> { $0.isFavorite == true },
       sort: \Route.favoritedAt)
private var favoriteRoutes: [Route]

@Query(filter: #Predicate<Route> { $0.isFavorite == false },
       sort: \Route.createdAt, order: .reverse)
private var normalRoutes: [Route]
```

**利点:**
- データベースレベルでのソート（高速）
- 大量データに強い

**欠点:**
- コードが複雑化
- 現状のアプリ規模では過剰設計の可能性

**推奨:** オプションA（シンプル実装）→ パフォーマンス問題が出たらオプションBへ移行

#### 2.2 HomeView.swiftの修正箇所

**変更前:**
```swift
@Query(sort: \Route.createdAt, order: .reverse) private var savedRoutes: [Route]

RouteListView(
    routes: savedRoutes,
    viewModel: viewModel,
    onDelete: deleteRoute
)
```

**変更後:**
```swift
@Query private var savedRoutes: [Route]

var sortedRoutes: [Route] {
    // お気に入り（登録順）+ 通常（新しい順）
    let favorites = savedRoutes
        .filter { $0.isFavorite }
        .sorted { ($0.favoritedAt ?? .distantPast) < ($1.favoritedAt ?? .distantPast) }

    let normals = savedRoutes
        .filter { !$0.isFavorite }
        .sorted { $0.createdAt > $1.createdAt }

    return favorites + normals
}

RouteListView(
    routes: sortedRoutes,  // ソート済みリストを渡す
    viewModel: viewModel,
    onDelete: deleteRoute
)
```

---

### フェーズ3: HomeCardViewの変更（スターアイコン）

#### 3.1 HomeCardView.swiftの確認

**現在のファイル構造を確認する必要あり:**
- `HomeCardView`の現在の実装を読む
- スターアイコンの配置位置を決定（右上？カード内の特定位置？）

#### 3.2 スターアイコンUI実装案

**配置案:**
- カードの右上隅にオーバーレイ表示
- タップ領域を十分に確保（44x44pt推奨）

**実装イメージ:**
```swift
struct HomeCardView: View {
    let routeEntity: Route
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // 既存のカードコンテンツ
            ExistingCardContent()

            // お気に入りスターアイコン
            Button {
                toggleFavorite()
            } label: {
                Image(systemName: routeEntity.isFavorite ? "star.fill" : "star")
                    .foregroundColor(routeEntity.isFavorite ? .yellow : .gray)
                    .font(.title3)
                    .padding(8)
            }
            .accessibilityLabel(routeEntity.isFavorite ? "お気に入りを解除" : "お気に入りに登録")
        }
    }

    private func toggleFavorite() {
        routeEntity.isFavorite.toggle()

        if routeEntity.isFavorite {
            routeEntity.favoritedAt = Date()
        } else {
            routeEntity.favoritedAt = nil
        }

        try? modelContext.save()
    }
}
```

**アクセシビリティ配慮:**
- VoiceOverでの操作説明
- タップ領域の最小サイズ確保（44x44pt）
- 状態変更時のハプティックフィードバック（オプション）

---

## 📊 実装手順とチェックリスト

### ステップ1: データモデル変更 ⏱️ 15分
- [ ] RouteModel.swiftに`isFavorite`と`favoritedAt`を追加
- [ ] アプリ実行してマイグレーション動作確認
- [ ] 既存ルートが正常に表示されることを確認

### ステップ2: HomeViewのソートロジック追加 ⏱️ 30分
- [ ] `sortedRoutes` computed propertyを実装
- [ ] RouteListViewに`sortedRoutes`を渡すよう変更
- [ ] ビルド＆実行で表示順が変わらないことを確認（まだお気に入りなし）

### ステップ3: HomeCardViewにスターアイコン追加 ⏱️ 45分
- [ ] HomeCardView.swiftを読んで構造把握
- [ ] スターアイコンUIを追加（ZStackでオーバーレイ）
- [ ] `toggleFavorite()`メソッド実装
- [ ] ビルド＆実行でスターアイコンが表示されることを確認

### ステップ4: 動作テスト ⏱️ 30分
- [ ] スターアイコンタップでお気に入り登録される
- [ ] お気に入りルートが一覧の上部に移動する
- [ ] お気に入り解除で通常位置に戻る
- [ ] お気に入り登録順が正しい（古い→新しい）
- [ ] 通常ルートの並び順が正しい（新しい→古い）
- [ ] アプリ再起動後も状態が保持される

### ステップ5: エッジケーステスト ⏱️ 20分
- [ ] すべてのルートをお気に入り登録
- [ ] すべてのルートをお気に入り解除
- [ ] お気に入りルートを削除
- [ ] 新しいルート追加後の並び順
- [ ] VoiceOverでの操作性確認

**合計見積もり工数:** 約2.5時間

---

## 🎨 UIデザイン参考

### スターアイコンの配置

```
┌─────────────────────────────────┐
│  カードコンテンツ            ★  │  ← 右上隅に配置
│                                 │
│  出発地: バス停A                │
│  目的地: バス停B                │
│  次のバス: 5分後                │
│                                 │
└─────────────────────────────────┘
```

### 色の推奨
- **お気に入り登録済み**: `.yellow`（iOS標準のスター色）
- **未登録**: `.gray.opacity(0.5)`（控えめ）
- **タップ時のアニメーション**: `.scaleEffect`で0.8→1.2→1.0

---

## ⚠️ 考慮事項とリスク

### アーキテクチャへの影響

**現状:** このプロジェクトはMVVM + Clean Architectureへの移行中

**お気に入り機能の位置づけ:**
- **Domain層**: 不要（シンプルなCRUD操作のため）
- **Data層**: 不要（SwiftDataが直接永続化を担当）
- **Presentation層**: HomeView, HomeCardViewの変更のみ

**判断理由:**
- お気に入りはUIの状態管理に近い（ビジネスロジックではない）
- SwiftDataの@Queryで十分対応可能
- 過剰な抽象化を避ける（YAGNI原則）

**将来的な拡張性:**
- お気に入りの同期機能が必要になった場合 → Repository/UseCase層を追加
- 複雑な並び替えロジックが必要になった場合 → UseCase層を検討

### パフォーマンス考慮

**現状の想定:**
- ルート数: 5〜20件程度（一般的なユーザー）
- Swift側でのソート処理: 十分高速

**スケーラビリティ:**
- 50件以上のルートがある場合、オプションB（複数クエリ）への移行を検討
- ただし、現実的にはそこまでルートが増えるユースケースは稀

### データマイグレーション

**SwiftDataの自動マイグレーション:**
- 新しいプロパティ追加は自動的に処理される
- デフォルト値（`false`, `nil`）が既存データに設定される
- **リスク**: ほぼゼロ（Swiftの標準的な動作）

**テストデータ:**
- 開発中のテストデータは再生成が必要な可能性
- 本番ユーザーデータへの影響はなし

---

## 📚 参考実装パターン

### iOS標準アプリの例
- **メール**: スターでフラグ付け、フラグ付きメールを上部表示
- **リマインダー**: スターで重要マーク、ソート順に影響
- **メモ**: ピン留めで上部固定

**本機能との類似性:**
- トグル式のお気に入り登録
- お気に入りアイテムの上部表示
- 視覚的にシンプル（セクション分けなし）

---

## 🚀 実装後の拡張可能性

### フェーズ2候補（優先度: 低）

1. **お気に入りの手動並び替え**
   - ドラッグ＆ドロップでお気に入り内の順序を変更
   - `favoriteOrder: Int`プロパティを追加

2. **お気に入りの最大数制限**
   - 例: 最大5件まで
   - お気に入り登録時にアラート表示

3. **お気に入りのカテゴリ分け**
   - 「通勤」「プライベート」などのカテゴリ
   - タグ機能の実装

4. **お気に入りの統計表示**
   - 使用頻度の可視化
   - よく使う時間帯の分析

**推奨アプローチ:**
- まずシンプルな実装（本仕様書の内容）を完成させる
- ユーザーフィードバックを収集
- 必要性が高い拡張機能から段階的に実装

---

## ✅ 承認とネクストステップ

### 要件承認
- [ ] UI/UX仕様の確認完了
- [ ] 技術実装プランの妥当性確認
- [ ] 工数見積もりの承認

### 実装開始前の準備
- [ ] 開発用のfeatureブランチ作成（`feature/favorite-routes`）
- [ ] 実装チェックリストの印刷またはタスク管理ツールへの登録
- [ ] 既存のルートデータのバックアップ（念のため）

### 実装開始
実装を開始する場合は、以下のコマンドで開始してください：

```bash
# featureブランチ作成
git checkout -b feature/favorite-routes

# 実装フェーズ開始
# このドキュメントの「実装手順とチェックリスト」に従って段階的に実装
```

---

**ドキュメント作成者:** Claude Code (Brainstorming Mode)
**最終更新:** 2025-10-26
**ステータス:** 要件確定 ✅ → 実装待ち ⏳
