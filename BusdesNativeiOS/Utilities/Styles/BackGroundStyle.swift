import SwiftUICore

struct CurvedRedBackground: Shape {
    var height: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: height))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX, y: height),
            control: CGPoint(x: rect.midX, y: height + height * 0.3)
        )
        path.closeSubpath()

        return path
    }
}
