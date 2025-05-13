import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: BaseView.Tab
    
    var body: some View {
        HStack(spacing: 0) {
            Spacer()
            TabBarButton(
                title: "Next bus",
                icon: "deskclock",
                isSelected: selectedTab == .home,
                action: {
                    selectedTab = .home
                }
            )
            Spacer()
            TabBarButton(
                title: "Timetable",
                icon: "calendar.badge.clock",
                isSelected: selectedTab == .timetable,
                action: {
                    selectedTab = .timetable
                }
            )
            Spacer()
        }
        .padding(5)
        .padding(.top, 10)
    }
}
