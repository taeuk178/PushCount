import SwiftUI

/// 아랫단이 보이는 입체 버튼.
///
/// 누르면 윗면이 아랫단 높이만큼 내려가 실제로 눌린 것처럼 보인다.
/// 운동 중에는 화면을 제대로 못 보기 때문에, 눌렸는지가 형태로 드러나는 게
/// 색 변화만 주는 것보다 확실하다.
public struct DSButtonStyle: ButtonStyle {

    private let palette: DesignPalette
    private let height: CGFloat
    private let depth: CGFloat
    private let radius: CGFloat
    private let foreground: Color

    public init(
        palette: DesignPalette = DesignColor.brand,
        height: CGFloat = 58,
        depth: CGFloat = 5,
        radius: CGFloat = DesignRadius.md,
        foreground: Color = DesignColor.white
    ) {
        self.palette = palette
        self.height = height
        self.depth = depth
        self.radius = radius
        self.foreground = foreground
    }

    public func makeBody(configuration: Configuration) -> some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .fill(palette.deep)
                .frame(height: height)
                .offset(y: depth)

            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .fill(palette.main)
                .frame(height: height)
                .overlay {
                    configuration.label
                        .font(DesignFont.headline)
                        .foregroundStyle(foreground)
                }
                .offset(y: configuration.isPressed ? depth : 0)
        }
        .frame(height: height + depth)
        .animation(.spring(response: 0.18, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

/// 테두리만 있는 보조 버튼. 주 동작과 나란히 둘 때 쓴다.
public struct DSQuietButtonStyle: ButtonStyle {

    private let height: CGFloat

    public init(height: CGFloat = 50) {
        self.height = height
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignFont.headline)
            .foregroundStyle(DesignColor.inkMuted)
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .background {
                RoundedRectangle(cornerRadius: DesignRadius.md, style: .continuous)
                    .stroke(DesignColor.line, lineWidth: 2)
            }
            .opacity(configuration.isPressed ? 0.55 : 1)
    }
}

/// 원형 아이콘 버튼. 헤더의 닫기, 잠금처럼 작은 동작에 쓴다.
public struct DSIconButton: View {

    private let systemName: String
    private let palette: DesignPalette
    private let size: CGFloat
    private let action: () -> Void

    public init(
        systemName: String,
        palette: DesignPalette = DesignColor.muted,
        size: CGFloat = 44,
        action: @escaping () -> Void
    ) {
        self.systemName = systemName
        self.palette = palette
        self.size = size
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: size * 0.38, weight: .bold, design: .rounded))
                .foregroundStyle(palette.deep)
                .frame(width: size, height: size)
                .background(palette.soft, in: Circle())
        }
        .buttonStyle(.plain)
    }
}
