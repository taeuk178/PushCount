import SwiftUI

public struct SharedButton: View {
    let title: String
    let action: () -> Void
    let style: ButtonStyle
    
    public enum ButtonStyle {
        case primary
        case secondary
        case destructive
    }
    
    public init(
        title: String,
        style: ButtonStyle = .primary,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(textColor)
                .frame(maxWidth: .infinity)
                .padding()
                .background(backgroundColor)
                .cornerRadius(8)
        }
    }
    
    private var backgroundColor: Color {
        switch style {
        case .primary:
            return .blue
        case .secondary:
            return .gray.opacity(0.2)
        case .destructive:
            return .red
        }
    }
    
    private var textColor: Color {
        switch style {
        case .primary, .destructive:
            return .white
        case .secondary:
            return .primary
        }
    }
}