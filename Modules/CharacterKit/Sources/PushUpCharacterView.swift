import SwiftUI
import DesignSystemKit

/// 푸시업하는 캐릭터.
///
/// `MotionKit` 의 `phase`(0 = 맨 아래, 1 = 맨 위)를 그대로 받아 몸을 움직인다.
/// 사용자가 내려가면 캐릭터도 내려간다.
///
/// 운동 중 사용자는 바닥을 보고 있어 숫자를 읽을 수 없다. 큰 도형이 내 동작에
/// 맞춰 움직이는 것은 초점 없이도 인지되므로, 이 뷰가 운동 화면의 주된
/// 정보 전달 수단이다.
public struct PushUpCharacterView: View {

    /// 그리기 기준 좌표계. 실제 크기는 `scale` 로 조절한다.
    private static let designSize = CGSize(width: 240, height: 160)

    /// 바닥 높이.
    private static let groundY: CGFloat = 132

    private let phase: Double
    private let mood: CharacterMood
    private let palette: DesignPalette
    private let scale: CGFloat

    public init(
        phase: Double,
        mood: CharacterMood = .working,
        palette: DesignPalette = DesignColor.brand,
        scale: CGFloat = 1
    ) {
        self.phase = min(max(phase, 0), 1)
        self.mood = mood
        self.palette = palette
        self.scale = scale
    }

    public var body: some View {
        Group {
            if mood.followsExternalPhase {
                // 위상은 12Hz 로 들어온다. 그대로 그리면 60fps 화면에서 툭툭
                // 끊기므로 갱신 간격만큼 선형 보간해 사이를 메운다.
                pose(phase)
                    .animation(.linear(duration: 1.0 / 12.0), value: phase)
            } else {
                TimelineView(.animation) { context in
                    pose(selfDrivenPhase(at: context.date))
                }
            }
        }
        .frame(width: Self.designSize.width, height: Self.designSize.height)
        .scaleEffect(scale)
        .frame(width: Self.designSize.width * scale, height: Self.designSize.height * scale)
        .accessibilityHidden(true)
    }
}

// MARK: - 자세

private extension PushUpCharacterView {

    /// 운동 중이 아닐 때 캐릭터가 스스로 만드는 위상.
    func selfDrivenPhase(at date: Date) -> Double {
        let t = date.timeIntervalSinceReferenceDate

        switch mood {
        case .cheering:
            // 짧고 빠르게 통통 뛴다.
            return 0.82 + 0.18 * abs(sin(t * 4.2))
        case .confused:
            return 0.62
        default:
            // 숨 쉬는 정도의 느린 상하 움직임. 팔을 편 높은 자세를 기본으로 둬야
            // 처져 보이지 않는다.
            return 0.80 + 0.09 * sin(t * 1.5)
        }
    }

    @ViewBuilder
    func pose(_ p: Double) -> some View {
        // 어깨가 가장 크게 움직이고, 엉덩이는 발을 축으로 그 선 위에 놓인다.
        // 이래야 몸이 판자처럼 곧게 유지된다.
        let shoulder = CGPoint(x: 78, y: lerp(112, 68, p))
        let feet = CGPoint(x: 208, y: Self.groundY - 2)
        let hip = pointOnLine(from: shoulder, to: feet, ratio: 0.62)
        let hand = CGPoint(x: 66, y: Self.groundY)

        // 내려갈수록 팔꿈치가 뒤로 벌어진다.
        let elbow = CGPoint(
            x: lerp(96, 74, p),
            y: (shoulder.y + hand.y) / 2
        )
        let headCenter = CGPoint(x: shoulder.x - 32, y: shoulder.y - 8)

        ZStack {
            groundShadow(p)

            limb(from: hip, to: feet, thickness: 18, color: palette.deep)
            foot(at: feet)

            limb(from: shoulder, to: hip, thickness: 34, color: palette.main)

            limb(from: shoulder, to: elbow, thickness: 15, color: palette.deep)
            limb(from: elbow, to: hand, thickness: 15, color: palette.deep)
            handBlob(at: hand)

            head(at: headCenter, p: p)

            if mood == .cheering {
                sparkles(around: headCenter)
            }
        }
        .frame(width: Self.designSize.width, height: Self.designSize.height)
    }

    /// 바닥 그림자. 몸이 내려올수록 진하고 좁아져 높이를 알려준다.
    func groundShadow(_ p: Double) -> some View {
        Ellipse()
            .fill(DesignColor.ink.opacity(0.16 - 0.07 * p))
            .frame(width: 150 - 18 * (1 - p), height: 14)
            .position(x: 136, y: Self.groundY + 12)
            .blur(radius: 4)
    }

    /// 두 점을 잇는 굵은 선. 팔다리와 몸통을 모두 이걸로 그린다.
    func limb(from a: CGPoint, to b: CGPoint, thickness: CGFloat, color: Color) -> some View {
        let dx = b.x - a.x
        let dy = b.y - a.y
        let length = sqrt(dx * dx + dy * dy)

        return Capsule(style: .continuous)
            .fill(color)
            .frame(width: max(length, thickness), height: thickness)
            .rotationEffect(.radians(atan2(dy, dx)))
            .position(x: (a.x + b.x) / 2, y: (a.y + b.y) / 2)
    }

    func handBlob(at point: CGPoint) -> some View {
        Capsule(style: .continuous)
            .fill(palette.deep)
            .frame(width: 26, height: 15)
            .position(x: point.x - 4, y: point.y)
    }

    func foot(at point: CGPoint) -> some View {
        Capsule(style: .continuous)
            .fill(palette.deep)
            .frame(width: 28, height: 16)
            .position(x: point.x + 6, y: point.y + 2)
    }
}

// MARK: - 얼굴

private extension PushUpCharacterView {

    func head(at center: CGPoint, p: Double) -> some View {
        ZStack {
            Circle()
                .fill(palette.main)
                .frame(width: 62, height: 62)

            face(p: p)
        }
        // 아래로 내려갈수록 살짝 눌린다. 힘이 들어간 느낌.
        .scaleEffect(x: 1 + 0.05 * (1 - p), y: 1 - 0.05 * (1 - p))
        .position(center)
    }

    @ViewBuilder
    func face(p: Double) -> some View {
        let eyeY: CGFloat = -6

        ZStack {
            switch mood {
            case .cheering:
                closedHappyEye(x: -13, y: eyeY)
                closedHappyEye(x: 7, y: eyeY)
                mouth(width: 20, height: 15, corner: 8, y: 14)

            case .confused:
                openEye(x: -13, y: eyeY, size: 9)
                openEye(x: 7, y: eyeY, size: 9)
                Capsule()
                    .fill(DesignColor.ink)
                    .frame(width: 14, height: 3)
                    .offset(x: -3, y: 13)

            case .working:
                // 아래로 내려갈수록 눈이 감기고 입이 벌어진다.
                if p < 0.35 {
                    strainEye(x: -13, y: eyeY)
                    strainEye(x: 7, y: eyeY)
                } else {
                    openEye(x: -13, y: eyeY, size: 8)
                    openEye(x: 7, y: eyeY, size: 8)
                }
                mouth(width: 13 + 7 * (1 - p), height: 8 + 6 * (1 - p), corner: 5, y: 13)

            case .resting:
                openEye(x: -13, y: eyeY, size: 8)
                openEye(x: 7, y: eyeY, size: 8)
                smile(y: 8)
            }
        }
        .offset(x: -4)
    }

    func openEye(x: CGFloat, y: CGFloat, size: CGFloat) -> some View {
        Circle()
            .fill(DesignColor.ink)
            .frame(width: size, height: size)
            .offset(x: x, y: y)
    }

    /// 힘줄 때 실눈.
    func strainEye(x: CGFloat, y: CGFloat) -> some View {
        Capsule()
            .fill(DesignColor.ink)
            .frame(width: 11, height: 3.5)
            .offset(x: x, y: y)
    }

    /// 기뻐서 감은 눈.
    func closedHappyEye(x: CGFloat, y: CGFloat) -> some View {
        Circle()
            .trim(from: 0.55, to: 0.95)
            .stroke(DesignColor.ink, style: StrokeStyle(lineWidth: 3.5, lineCap: .round))
            .frame(width: 14, height: 14)
            .offset(x: x, y: y)
    }

    /// 대기 상태의 웃는 입. 아래로 열린 호라서 각도 없이도 웃음으로 읽힌다.
    func smile(y: CGFloat) -> some View {
        Circle()
            .trim(from: 0.08, to: 0.42)
            .stroke(DesignColor.ink, style: StrokeStyle(lineWidth: 3.5, lineCap: .round))
            .frame(width: 22, height: 22)
            .offset(x: -3, y: y)
    }

    func mouth(width: CGFloat, height: CGFloat, corner: CGFloat, y: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: corner, style: .continuous)
            .fill(DesignColor.ink.opacity(0.85))
            .frame(width: width, height: height)
            .offset(x: -3, y: y)
    }

    func sparkles(around center: CGPoint) -> some View {
        ZStack {
            ForEach(0..<3, id: \.self) { index in
                Image(systemName: "sparkle")
                    .font(.system(size: [15.0, 11.0, 13.0][index], weight: .black))
                    .foregroundStyle(DesignColor.sunny.main)
                    .offset(
                        x: [-34.0, 22.0, -6.0][index],
                        y: [-30.0, -38.0, -46.0][index]
                    )
            }
        }
        .position(center)
    }
}

// MARK: - 계산

private extension PushUpCharacterView {

    func lerp(_ from: CGFloat, _ to: CGFloat, _ t: Double) -> CGFloat {
        from + (to - from) * CGFloat(t)
    }

    func pointOnLine(from a: CGPoint, to b: CGPoint, ratio: CGFloat) -> CGPoint {
        CGPoint(x: a.x + (b.x - a.x) * ratio, y: a.y + (b.y - a.y) * ratio)
    }
}

#Preview("자세 단계") {
    VStack(spacing: 0) {
        ForEach([1.0, 0.6, 0.0], id: \.self) { phase in
            PushUpCharacterView(phase: phase, mood: .working, scale: 0.9)
        }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(DesignColor.canvas)
}

#Preview("표정") {
    VStack(spacing: 0) {
        PushUpCharacterView(phase: 0.7, mood: .resting, scale: 0.9)
        PushUpCharacterView(phase: 0.7, mood: .confused, palette: DesignColor.sunny, scale: 0.9)
        PushUpCharacterView(phase: 0.9, mood: .cheering, palette: DesignColor.success, scale: 0.9)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(DesignColor.canvas)
}
