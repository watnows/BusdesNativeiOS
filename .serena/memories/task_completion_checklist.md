# タスク完了時のチェックリスト

## コード変更後の必須確認

### 1. ビルド確認
```bash
# Xcodeでビルド
⌘+B

# または、コマンドライン
xcodebuild -project BusdesNativeiOS.xcodeproj -scheme BusdesNativeiOS build
```
- [ ] ビルドエラーなし
- [ ] 警告を確認・対処

### 2. テスト実行
```bash
# Xcodeでテスト
⌘+U

# または、コマンドライン
xcodebuild -project BusdesNativeiOS.xcodeproj -scheme BusdesNativeiOS test
```
- [ ] 既存テストが全てパス
- [ ] 新規機能にテスト追加（必要に応じて）

### 3. 実行確認
```bash
# Simulatorで実行
⌘+R
```
- [ ] アプリが正常に起動
- [ ] 変更した機能が期待通り動作
- [ ] 既存機能に影響なし

### 4. コード品質

#### アーキテクチャ準拠
- [ ] 新コードがMVVM + Clean Architectureパターンに従っている
- [ ] 依存注入が適切に実装されている
- [ ] ViewModelは抽象に依存している

#### 命名規約
- [ ] Repository: `~Repository` / `~RepositoryImpl`
- [ ] UseCase: `~UseCase`
- [ ] DTO: `~DTO`, Mapper: `~Mapper`
- [ ] ViewModel: `@Observable` + `@MainActor` + State構造体

#### 並行処理
- [ ] `async/await`を適切に使用
- [ ] `@MainActor`でUI更新を保護
- [ ] Swift 6並行処理モデルに準拠

#### エラーハンドリング
- [ ] 適切なエラー型を使用（AppError, NetworkError）
- [ ] エラーケースを適切に処理
- [ ] ユーザーにわかりやすいエラーメッセージ

### 5. コードレビュー自己チェック

#### 可読性
- [ ] コメントが適切に記述されている
- [ ] MARK: でセクション分割されている
- [ ] 複雑なロジックに説明がある

#### 保守性
- [ ] 重複コードがない
- [ ] 関数が適切な長さに分割されている
- [ ] マジックナンバーが定数化されている

#### パフォーマンス
- [ ] 不要なAPI呼び出しがない
- [ ] 適切なキャッシング戦略
- [ ] メモリリークの可能性がない

## Git操作

### コミット前
```bash
# 変更内容確認
git status
git diff

# ステージング
git add .
```
- [ ] 意図したファイルのみ変更されている
- [ ] 不要なファイルが含まれていない

### コミットメッセージ
- [ ] 適切な絵文字プレフィックス (✨🐛♻️等)
- [ ] 変更内容が簡潔に説明されている

### プッシュ前
```bash
# リモートの最新状態を取得
git fetch origin
git status
```
- [ ] リモートとの差分を確認
- [ ] コンフリクトがない

## ドキュメント更新

### 必要に応じて更新
- [ ] CLAUDE.md: アーキテクチャ変更時
- [ ] README: 大きな機能追加時
- [ ] コメント: 複雑なロジック追加時

## 新機能追加時の特別チェック

### Clean Architecture移行中の考慮事項
1. [ ] Domain層でEntity/UseCase/Repository抽象を定義
2. [ ] Data層でRepository実装・DTO・Mapper作成
3. [ ] Presentation層でViewModel・View作成
4. [ ] App層でDI配線追加

### テスト追加
- [ ] Domain: モックRepositoryでUseCaseをテスト
- [ ] Data: URLProtocolスタブで統合テスト
- [ ] Presentation: モックUseCaseでViewModelをテスト

## 完了基準

全ての項目をクリアしたら、タスク完了とみなす。
不明点や懸念事項があれば、チームメンバーに相談する。
