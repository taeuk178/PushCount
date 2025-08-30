import SwiftUI

public struct SharedTextField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    let isSecure: Bool
    
    public init(
        title: String,
        text: Binding<String>,
        placeholder: String = "",
        isSecure: Bool = false
    ) {
        self.title = title
        self._text = text
        self.placeholder = placeholder
        self.isSecure = isSecure
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !title.isEmpty {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            
            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}