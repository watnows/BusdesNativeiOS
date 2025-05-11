// Custom Tab Bar Container View
struct CustomTabBar: View {
    @Binding var selectedTab: BaseView.Tab

    var body: some View {
        HStack(spacing: 0) { // Use spacing: 0 if buttons should touch
            TabBarButton(
                title: "Next bus",
                icon: "deskclock",
                isSelected: selectedTab == .home,
                action: {
                    selectedTab = .home
                }
            )

            TabBarButton(
                title: "Timetable",
                icon: "calendar.badge.clock",
                isSelected: selectedTab == .timetable,
                action: {
                    selectedTab = .timetable
                }
            )
        }
        .frame(height: 55) // Adjust height as needed, including safe area padding consideration
        .padding(.bottom, UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0 > 0 ? 15 : 0) // Add padding only if safe area exists
        .background(Color(uiColor: .systemBackground)) // Background for the tab bar area
        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: -2) // Optional shadow
    }
}