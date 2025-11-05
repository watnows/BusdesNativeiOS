import SwiftUI
import SwiftData
import os.log

struct HomeView: View {
    @Binding var path: NavigationPath

    // SwiftDataから直接クエリ（自動UI更新）
    @Query private var savedRoutes: [Route]

    // ViewModelはリアルタイムバス情報のみ管理
    @State private var viewModel = HomeViewModel()

    // ModelContext（削除操作用）
    @Environment(\.modelContext) private var modelContext

    // 広告サービス（シングルトン直接参照）
    private var adService: AdService { AdService.shared }

    private let appBarHeight: CGFloat = UIScreen.main.bounds.height * 0.35

    // お気に入り優先でソート済みのルート一覧
    private var sortedRoutes: [Route] {
        let favorites = savedRoutes
            .filter { $0.isFavorite }
            .sorted { ($0.favoritedAt ?? .distantPast) < ($1.favoritedAt ?? .distantPast) }

        let normals = savedRoutes
            .filter { !$0.isFavorite }
            .sorted { $0.createdAt > $1.createdAt }

        return favorites + normals
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                if savedRoutes.isEmpty {
                    EmptyRouteView()
                } else {
                    RouteListView(
                        routes: sortedRoutes,  // ソート済みリストを渡す
                        viewModel: viewModel,
                        onDelete: deleteRoute
                    )
                    .refreshable {
                        // バス情報更新時に選択をリセット（常に最初のバスに戻る）
                        viewModel.resetAllSelections()
                        await viewModel.fetchAllTimeTables(for: savedRoutes)
                    }
                }

                // バナー広告
                if adService.isInitialized {
                    BannerAdView()
                        .frame(height: 50)
                        .background(Color.gray.opacity(0.1))
                }
            }

            AddRouteButton(path: $path)
        }
        .task {
            // 初回表示時とルート変更時にバス情報取得開始
            await viewModel.startRealtimeUpdates(for: savedRoutes)
        }
        .onChange(of: savedRoutes) { oldValue, newValue in
            // 路線が変更されたらリアルタイム更新も更新
            Task {
                await viewModel.updateRoutes(newValue)
            }
        }
    }

    // MARK: - Helper Methods

    private func deleteRoute(_ route: Route) {
        modelContext.delete(route)
        do {
            try modelContext.save()
        } catch {
            Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.busdes", category: "HomeView")
                .error("路線削除エラー: \(error.localizedDescription)")
        }
    }
}

// MARK: - Subviews

/// 路線が空の時の表示
private struct EmptyRouteView: View {
    @ScaledMetric private var fontSize: CGFloat = 16

    var body: some View {
        VStack {
            Spacer()
            Text("右下の「+」ボタンから\nよく使う路線を追加してください")
                .font(.system(size: fontSize))
                .foregroundColor(.appGray)
                .multilineTextAlignment(.center)
                .padding()
                .accessibilityLabel("路線が登録されていません。右下の追加ボタンから、よく使う路線を追加してください")
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// 路線リスト表示
private struct RouteListView: View {
    let routes: [Route]
    let viewModel: HomeViewModel
    let onDelete: (Route) -> Void

    var body: some View {
        List {
            ForEach(routes) { route in
                HomeCardView(viewModel: viewModel, routeEntity: route)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            onDelete(route)
                        } label: {
                            Label("削除", systemImage: "trash.fill")
                        }
                        .tint(.red)
                        .accessibilityLabel("\(route.from)から\(route.to)への路線を削除")
                    }
                    .listRowSpacing(30)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
                    .listRowBackground(Color.clear)
                    .opacity(0.9)
                    .accessibilityElement(children: .combine)
            }
        }
        .shadow(radius: 1)
        .listStyle(.plain)
    }
}

/// 路線追加ボタン
private struct AddRouteButton: View {
    @Binding var path: NavigationPath
    @ScaledMetric private var buttonSize: CGFloat = 60

    var body: some View {
        Button {
            path.append(AppScreen.addLine)
        } label: {
            Image(systemName: "plus")
                .font(.title.weight(.semibold))
                .padding()
                .background(Color.appRed)
                .foregroundColor(.white)
                .clipShape(Circle())
                .shadow(color: .gray, radius: 3, x: 1, y: 1)
        }
        .frame(width: buttonSize, height: buttonSize)
        .padding()
        .accessibilityLabel("新しい路線を追加")
        .accessibilityHint("タップして出発地と目的地を選択")
    }
}

//#Preview {
//    let userService = UserService()
//    HomeView(path: .constant(NavigationPath()))
//        .environmentObject(userService)
//        .environmentObject(HomeViewModel(userModel: userService))
//        .environmentObject(AdService.shared)
//}
