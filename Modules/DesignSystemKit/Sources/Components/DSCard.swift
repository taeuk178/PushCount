import SwiftUI

/// 바탕 위에 떠 있는 흰 카드.
///
/// 테두리 대신 옅은 그림자로 띄운다. 밝은 배경에서는 선을 그을수록
/// 화면이 답답해지고, 그림자 쪽이 캐릭터의 부드러운 인상과도 맞는다.
public struct DSCard<Content: View>: View {

    private let padding: CGFloat
    private let radius: CGFloat
    private let background: Color
    private let content: Content

    public init(
        padding: CGFloat = DesignSpacing.md,
        radius: CGFloat = DesignRadius.lg,
        background: Color = DesignColor.surface,
        @ViewBuilder content: () -> Content
    ) {
        self.padding = padding
        self.radius = radius
        self.background = background
        self.content = content()
    }

    public var body: some View {
        content
            .padding(padding)
            .background(background, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
            .shadow(color: DesignColor.ink.opacity(0.06), radius: 12, y: 4)
    }
}

/// 작은 태그. 강도, 소요 시간, 상태 표시.
public struct DSPill: View {

    private let text: String
    private let systemImage: String?
    private let palette: DesignPalette

    public init(_ text: String, systemImage: String? = nil, palette: DesignPalette = DesignColor.brand) {
        self.text = text
        self.systemImage = systemImage
        self.palette = palette
    }

    public var body: some View {
        HStack(spacing: DesignSpacing.xs) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(DesignFont.caption)
            }
            Text(text)
                .font(DesignFont.label)
        }
        .foregroundStyle(palette.deep)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(palette.soft, in: Capsule())
    }
}

/// 값 + 라벨 한 쌍. 결과와 기록 화면의 지표에 쓴다.
public struct DSStat: View {

    private let value: String
    private let label: String
    private let size: CGFloat

    public init(value: String, label: String, size: CGFloat = 26) {
        self.value = value
        self.label = label
        self.size = size
    }

    public var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(DesignFont.numeric(size))
                .foregroundStyle(DesignColor.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.6)

            Text(label)
                .font(DesignFont.label)
                .foregroundStyle(DesignColor.inkMuted)
        }
        .frame(maxWidth: .infinity)
    }
}

/// 목표까지 얼마나 왔는지 보여주는 막대.
public struct DSProgressBar: View {

    private let progress: Double
    private let palette: DesignPalette
    private let height: CGFloat

    public init(progress: Double, palette: DesignPalette = DesignColor.brand, height: CGFloat = 12) {
        self.progress = min(max(progress, 0), 1)
        self.palette = palette
        self.height = height
    }

    public var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                // 트랙을 `soft` 로 두면 같은 틴트를 깐 배경 위에서 사라진다.
                // 흰 카드 위에서도 옅은 틴트 위에서도 보이는 농도로 잡는다.
                Capsule().fill(palette.main.opacity(0.2))
                Capsule()
                    .fill(palette.main)
                    .frame(width: max(proxy.size.width * progress, progress > 0 ? height : 0))
            }
        }
        .frame(height: height)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: progress)
    }
}
