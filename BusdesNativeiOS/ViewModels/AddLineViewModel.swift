import Foundation
import Observation

/// バス停選択画面のViewModel
///
/// ## 概要
/// 新しいバス路線を追加する際の出発地選択を管理するViewModelです。
/// `@Observable`マクロによる状態管理とリポジトリパターンにより、
/// テスタブルで保守性の高い実装を実現しています。
///
/// ## 主な機能
/// - バス停データのJSONファイルからの読み込み
/// - リアルタイム検索フィルタリング（名前・かな両対応）
/// - ローディング状態の管理
/// - エラーハンドリングとユーザーフィードバック
///
/// ## 使用例
/// ```swift
/// struct AddLineView: View {
///     @State private var viewModel = AddLineViewModel()
///
///     var body: some View {
///         SearchableList(
///             items: viewModel.state.filteredData,
///             searchText: $viewModel.state.searchQuery
///         )
///         .onChange(of: viewModel.state.searchQuery) { _, newValue in
///             viewModel.filterBusStops(with: newValue)
///         }
///     }
/// }
/// ```
///
/// ## アーキテクチャパターン
/// - **依存注入**: `BusStopRepository`をコンストラクタ注入でテスト容易性を確保
/// - **State管理**: 単一の`State`構造体で全状態を集約
/// - **エラーハンドリング**: `LoadingState`による統一的なエラー管理
/// - **リアクティブUI**: `@Observable`により状態変更が自動的にUIへ反映
@MainActor
@Observable
final class AddLineViewModel {

    // MARK: - State

    /// 画面の状態を1つの構造体で管理
    ///
    /// ## プロパティ
    /// - `searchQuery`: ユーザー入力の検索クエリ
    /// - `filteredData`: フィルタリング後のバス停リスト（UI表示用）
    /// - `loadingState`: ローディング・エラー状態の管理
    ///
    /// ## 設計意図
    /// 状態を単一の構造体に集約することで、
    /// 状態の整合性を保ちやすく、デバッグも容易になります。
    struct State {
        /// 検索クエリ（ユーザー入力）
        /// SearchBarやTextFieldにバインドされ、リアルタイムでフィルタリングに使用されます
        var searchQuery: String = ""

        /// フィルタリング後のバス停リスト
        /// UI表示用のデータソース。検索クエリに応じて動的に更新されます
        var filteredData: [BusStop] = []

        /// ローディング・エラー状態
        /// データ読み込み中、成功、失敗の3状態を管理します
        var loadingState = LoadingState()
    }

    var state = State()

    // MARK: - Dependencies

    /// 全バス停データ（検索元データ）
    /// JSONファイルから読み込まれたマスターデータを保持します
    private var busStops: [BusStop] = []

    /// バス停データリポジトリ
    /// JSONファイルからのデータ読み込みを抽象化します
    /// テスト時にはモックリポジトリを注入可能です
    private let busStopRepository: BusStopRepository

    // MARK: - Initialization

    /// イニシャライザ
    ///
    /// ## 概要
    /// ViewModelを初期化し、バス停データの読み込みを開始します。
    /// 読み込みは同期的に実行され、初期化完了時には
    /// `state.filteredData`に全バス停が設定されています。
    ///
    /// ## パラメータ
    /// - Parameter busStopRepository: バス停データリポジトリ（デフォルト: shared singleton）
    ///   テスト時にはモックリポジトリを注入して動作をカスタマイズできます
    ///
    /// ## エラーハンドリング
    /// データ読み込みに失敗した場合、`state.loadingState`にエラーメッセージが設定され、
    /// `state.filteredData`は空配列になります。
    ///
    /// ## 使用例
    /// ```swift
    /// // 本番環境（デフォルトリポジトリ使用）
    /// let viewModel = AddLineViewModel()
    ///
    /// // テスト環境（モックリポジトリ注入）
    /// let mockRepo = MockBusStopRepository()
    /// let viewModel = AddLineViewModel(busStopRepository: mockRepo)
    /// ```
    init(busStopRepository: BusStopRepository = BusStopRepository.shared) {
        self.busStopRepository = busStopRepository
        loadBusStops()
    }

    // MARK: - Private Methods

    /// バス停一覧をJSONファイルから読み込む
    ///
    /// ## 処理フロー
    /// 1. `loadingState.startLoading()`: ローディング状態を開始
    /// 2. `busStopRepository.getBusStops()`: バス停データを取得
    /// 3. 成功時: `busStops`と`filteredData`に全バス停を設定、ローディング完了
    /// 4. 失敗時: 空配列を設定、エラーメッセージを`loadingState`に格納
    ///
    /// ## エラーケース
    /// - **JSONファイルが存在しない**: バンドルにbus_stops.jsonが含まれていない
    /// - **JSONパース失敗**: ファイル形式が不正、または`BusStop`モデルと不一致
    /// - **アクセス権限エラー**: ファイル読み込み権限がない（稀）
    ///
    /// ## 副作用
    /// - `state.loadingState`: ローディング状態が更新されます
    /// - `state.filteredData`: 読み込まれた全バス停が設定されます
    /// - `busStops`: 内部マスターデータが更新されます
    ///
    /// ## 使用例（内部用）
    /// このメソッドは`init()`から自動的に呼び出されるため、
    /// 通常は外部から直接呼び出す必要はありません。
    private func loadBusStops() {
        state.loadingState.startLoading()

        do {
            busStops = try busStopRepository.getBusStops()
            state.filteredData = busStops
            state.loadingState.finishLoading()
        } catch {
            busStops = []
            state.filteredData = []
            state.loadingState.failLoading(with: "バス停データの読み込みに失敗しました")
        }
    }

    // MARK: - Public Methods

    /// 検索クエリでバス停をフィルタリング
    ///
    /// ## 概要
    /// ユーザー入力の検索クエリに基づいて、バス停リストをリアルタイムでフィルタリングします。
    /// 検索は部分一致で行われ、バス停名（漢字）とかな名の両方が対象です。
    ///
    /// ## パラメータ
    /// - Parameter query: 検索文字列
    ///   - 空文字列の場合: 全バス停を表示（フィルタなし）
    ///   - 非空の場合: 名前またはかな名に部分一致するバス停のみを表示
    ///
    /// ## フィルタリングロジック
    /// - **バス停名**: 漢字表記（例: "立命館大学"）での部分一致
    /// - **かな名**: ひらがな表記（例: "りつめいかんだいがく"）での部分一致
    /// - **OR条件**: どちらか一方に一致すれば結果に含まれます
    ///
    /// ## パフォーマンス
    /// - 時間計算量: O(n) where n = バス停総数
    /// - 空間計算量: O(m) where m = フィルタ結果数
    /// - バス停数が数百件程度であれば、リアルタイム検索でも十分高速です
    ///
    /// ## 使用例
    /// ```swift
    /// // SearchBarやTextFieldの変更を監視
    /// .onChange(of: searchQuery) { _, newValue in
    ///     viewModel.filterBusStops(with: newValue)
    /// }
    ///
    /// // 検索例:
    /// viewModel.filterBusStops(with: "")           // → 全バス停表示
    /// viewModel.filterBusStops(with: "立命館")     // → "立命館大学", "立命館..."
    /// viewModel.filterBusStops(with: "りつめい")   // → かな名で部分一致
    /// ```
    ///
    /// ## 副作用
    /// - `state.searchQuery`: 検索クエリが更新されます
    /// - `state.filteredData`: フィルタリング結果が更新されます（UI自動更新）
    func filterBusStops(with query: String) {
        state.searchQuery = query

        if query.isEmpty {
            state.filteredData = busStops
        } else {
            state.filteredData = busStops.filter {
                $0.name.contains(query) || $0.kana.contains(query)
            }
        }
    }
}
