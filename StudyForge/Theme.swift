import SwiftUI

enum StudyForgeTheme {
    static let violet = Color(red: 124/255, green: 92/255, blue: 252/255)
    static let graphite = Color(red: 17/255, green: 18/255, blue: 22/255)
    static let secondary = Color.secondary
}

struct FrostCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .strokeBorder(.white.opacity(0.08))
            }
    }
}

extension View {
    func frostCard() -> some View { modifier(FrostCardModifier()) }
}
