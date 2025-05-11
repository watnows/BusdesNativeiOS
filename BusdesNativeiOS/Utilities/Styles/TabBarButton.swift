import SwiftUI

struct TabBarButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack() {
                Image(systemName: icon)
                    .font(.callout)
                Text(title)
                    .font(.callout)
            }
        }
        .buttonStyle(.plain)
        .padding(4)
        .frame(maxWidth: .infinity)
        .frame(width: 150, height: 40)
        .foregroundColor(isSelected ? Color.white: Color.appRed)
        .background(isSelected ? Color.appRed: Color.clear)
        .cornerRadius(50)
    }
}
