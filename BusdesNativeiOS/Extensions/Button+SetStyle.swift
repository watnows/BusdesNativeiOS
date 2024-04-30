import SwiftUI

struct RoundedButton: ButtonStyle {
    let isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: 130, height: 40)
            .foregroundColor(.white)
            // 有効無効でカラーを変更
            .background(isSelected ? Color.appRed : Color.appGray)
            // 押下時かどうかで透明度を変更
            .opacity(configuration.isPressed ? 0.5 : 1.0)
            .clipShape(Capsule())
    }
}
