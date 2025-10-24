import SwiftUI
import SwiftData
import os.log

struct HomeView: View {
    @Binding var path: NavigationPath

    // SwiftDataから直接クエリ（自動UI更新、新しい順）
    @Query(sort: \Route.createdAt, order: .reverse) private var savedRoutes: [Route]

    // ViewModelはリアルタイムバス情報のみ管理
    @State private var viewModel = HomeViewModel()

    // ModelContext（削除操作用）
    @Environment(\.modelContext) private var modelContext

    // 広告サービス（シングルトン直接参照）
    private var adService: AdService { AdService.shared }

    private let appBarHeight: CGFloat = UIScreen.main.bounds.height * 0.35

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                if savedRoutes.isEmpty {
                    EmptyRouteView()
                } else {
                    RouteListView(
                        routes: savedRoutes,
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
    var body: some View {
        VStack {
            Spacer()
            Text("右下の「+」ボタンから\nよく使う路線を追加してください")
                .foregroundColor(.appGray)
                .multilineTextAlignment(.center)
                .padding()
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
                    }
                    .listRowSpacing(30)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
                    .listRowBackground(Color.clear)
                    .opacity(0.9)
            }
        }
        .shadow(radius: 1)
        .listStyle(.plain)
    }
}

/// 路線追加ボタン
private struct AddRouteButton: View {
    @Binding var path: NavigationPath

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
        .padding()
    }
}

//#Preview {
//    let userService = UserService()
//    HomeView(path: .constant(NavigationPath()))
//        .environmentObject(userService)
//        .environmentObject(HomeViewModel(userModel: userService))
//        .environmentObject(AdService.shared)
//}
