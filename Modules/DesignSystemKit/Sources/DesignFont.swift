import SwiftUI

/// 타이포 스케일.
///
/// 전부 `.rounded` 로 통일한다. 캐릭터 중심의 밝고 긍정적인 톤에서
/// 기본 SF 의 각진 인상이 가장 크게 어긋나는 부분이라 여기서 잡는다.
///
/// 단계를 6개로 제한한 건 의도적이다. 중간 크기를 늘릴수록 화면 간
/// 위계가 흐려지고, 큰 글자가 커 보이지 않는다.
public enum DesignFont {

    /// 화면 제목. 한 화면에 하나만.
    public static let display = Font.system(size: 30, weight: .black, design: .rounded)

    /// 섹션 제목, 카드 제목.
    public static let title = Font.system(size: 22, weight: .heavy, design: .rounded)

    /// 강조 본문, 버튼 라벨.
    public static let headline = Font.system(size: 17, weight: .bold, design: .rounded)

    /// 본문.
    public static let body = Font.system(size: 15, weight: .medium, design: .rounded)

    /// 라벨, 보조 설명.
    public static let label = Font.system(size: 13, weight: .semibold, design: .rounded)

    /// 태그, 눈금.
    public static let caption = Font.system(size: 11, weight: .bold, design: .rounded)

    /// 카운터처럼 값이 계속 바뀌는 숫자.
    ///
    /// `monospacedDigit` 이 없으면 `1 → 2` 처럼 자릿수가 같아도 글자 폭이
    /// 달라져 숫자가 좌우로 흔들린다. 운동 중에는 그 흔들림이 크게 거슬린다.
    public static func counter(_ size: CGFloat) -> Font {
        .system(size: size, weight: .black, design: .rounded).monospacedDigit()
    }

    /// 지표값처럼 크지 않은 숫자.
    public static func numeric(_ size: CGFloat) -> Font {
        .system(size: size, weight: .heavy, design: .rounded).monospacedDigit()
    }
}

/// 여백과 라운드 값.
public enum DesignSpacing {
    public static let xs: CGFloat = 4
    public static let sm: CGFloat = 8
    public static let md: CGFloat = 16
    public static let lg: CGFloat = 24
    public static let xl: CGFloat = 32
    public static let xxl: CGFloat = 48

    /// 화면 좌우 기본 여백.
    public static let screen: CGFloat = 20
}

public enum DesignRadius {
    public static let sm: CGFloat = 12
    public static let md: CGFloat = 18
    public static let lg: CGFloat = 26
    public static let xl: CGFloat = 34
}
