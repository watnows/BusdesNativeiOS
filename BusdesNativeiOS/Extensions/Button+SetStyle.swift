import SwiftUI

struct RoundedRedButton: ButtonStyle {
    let isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: 130, height: 40)
            .foregroundColor(isSelected ? .white : .black)
            .background(isSelected ? Color.appRed : Color.appGray)
            .opacity(configuration.isPressed ? 0.5 : 1.0)
            .clipShape(Capsule())
    }
}

struct RoundedGrayButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: 130, height: 40)
            .foregroundColor(.black)
            .background(Color.appGray)
            .opacity(configuration.isPressed ? 0.5 : 1.0)
            .clipShape(Capsule())
    }
}
