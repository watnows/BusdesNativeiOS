import SwiftUI

struct HomeView: View {
    @Binding var path: NavigationPath
    @EnvironmentObject var userModel: UserService
    @EnvironmentObject var viewModel: HomeViewModel
    
    private let appBarHeight: CGFloat = UIScreen.main.bounds.height * 0.35
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            if userModel.savedRoutes.isEmpty {
                VStack {
                    Spacer()
                    Text("右下の「+」ボタンから\nよく使う路線を追加してください")
                        .foregroundColor(.appGray)
                        .multilineTextAlignment(.center)
                        .padding()
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(userModel.savedRoutes) { route in
                        HomeCardView(routeEntity: route)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    userModel.deleteRoute(route)
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
                .refreshable {
                    await Task {
                        await viewModel.fetchAllTimeTables()
                    }.value
                }
            }
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
}
