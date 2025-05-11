// Custom Tab Bar Button View
struct TabBarButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) { // Arrange icon and text vertically
                 Image(systemName: icon)
                     .font(.system(size: 20)) // Adjust icon size
                 Text(title)
                     .font(.caption) // Adjust text size
            }
            .frame(maxWidth: .infinity) // Ensure button takes up available horizontal space
            .frame(height: 55)          // Match the height of the CustomTabBar
            .foregroundColor(isSelected ? Color.appRed : Color.gray) // Active/inactive color
            // Optional: Add a background highlight for the selected state if needed beyond color change
            // .background(isSelected ? Color.appRed.opacity(0.1) : Color.clear)
            // .cornerRadius(10) // Example if background highlight is used
        }
        .buttonStyle(.plain) // Use plain button style to remove default button visuals
    }
}