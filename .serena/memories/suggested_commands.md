# 開発コマンド一覧

## ビルドコマンド

### Xcode GUI
- **ビルド**: `⌘+B`
- **実行**: `⌘+R`
- **テスト**: `⌘+U`
- **クリーンビルド**: `⌘+Shift+K`

### コマンドライン
```bash
# プロジェクトビルド
xcodebuild -project BusdesNativeiOS.xcodeproj -scheme BusdesNativeiOS build

# テスト実行
xcodebuild -project BusdesNativeiOS.xcodeproj -scheme BusdesNativeiOS test

# クリーンビルド
xcodebuild -project BusdesNativeiOS.xcodeproj -scheme BusdesNativeiOS clean build
```

## 実行環境
- **Simulator**: Xcodeから`⌘+R`
- **実機**: 実機接続後、Xcodeから`⌘+R`

## Git操作

### 基本操作
```bash
# 現在の状態確認
git status
git branch

# ブランチ作成
git checkout -b feature/new-feature

# コミット
git add .
git commit -m "✨ Feat: 機能説明"

# プッシュ
git push origin feature/new-feature
```

### コミットメッセージ規約
- ✨ Feat: 新機能追加
- 🐛 Fix: バグ修正
- ♻️ Refactor: リファクタリング
- ♿ Accessibility: アクセシビリティ改善
- 📝 Docs: ドキュメント更新
- ⚡ Perf: パフォーマンス改善

## macOS/Darwin固有コマンド

### ファイル操作
```bash
# ファイル検索
find BusdesNativeiOS -name "*.swift"

# ディレクトリ一覧
ls -la

# パターン検索
grep -r "HomeViewModel" BusdesNativeiOS/
```

### プロジェクト情報
```bash
# Swiftファイル数カウント
find BusdesNativeiOS -name "*.swift" | wc -l

# コミット履歴
git log --oneline -10

# ブランチ一覧
git branch -a
```

## デバッグ

### Xcodeデバッガ
- ブレークポイント設定: 行番号クリック
- デバッグ実行: `⌘+R` (デバッグモード)
- ステップ実行: F6 (ステップオーバー), F7 (ステップイン)

### ログ出力
- `print()`: 基本的なログ
- `debugPrint()`: デバッグ情報付き
- Xcodeコンソールで確認

## 依存関係管理
現在はSwift Package Manager (SPM) を使用していません。
将来的に外部ライブラリを追加する場合はSPMまたはCocoaPodsを検討。

## パフォーマンス計測
- Instruments: Xcode > Product > Profile (`⌘+I`)
- Time Profiler: CPU使用率
- Allocations: メモリ使用量
