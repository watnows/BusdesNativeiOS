import SwiftUI

struct HomeView: View {
    @Binding var path: NavigationPath
    @EnvironmentObject var userModel: UserSession
    @EnvironmentObject var viewModel: HomeViewModel
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            if userModel.savedRoutes.isEmpty {
                VStack {
                    Spacer()
                    Text("右下の「+」ボタンから\nよく使う路線を追加してください")
                        .foregroundColor(.gray)
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
                            }
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .listRowBackground(Color.clear)
                    }
                }
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
