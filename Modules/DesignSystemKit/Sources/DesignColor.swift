import SwiftUI

/// 운동 종목이나 상태 하나가 쓰는 색 묶음.
///
/// `main` 하나만으로는 입체 버튼의 아랫단이나 배경 틴트를 만들 수 없어서
/// 명도만 다른 세 값을 한 벌로 들고 다닌다.
public struct DesignPalette: Sendable {

    /// 기본 채움색. 버튼 윗면, 아이콘, 강조 텍스트.
    public let main: Color

    /// `main` 보다 어두운 색. 입체 버튼의 아랫단과 그림자.
    public let deep: Color

    /// 배경에 깔리는 옅은 틴트. 본문 텍스트를 얹어도 읽힌다.
    public let soft: Color

    public init(main: Color, deep: Color, soft: Color) {
        self.main = main
        self.deep = deep
        self.soft = soft
    }
}

public enum DesignColor {

    // MARK: - 바탕

    /// 앱 전체 배경. 순백 대신 살짝 따뜻한 톤이라 오래 봐도 눈이 편하다.
    public static let canvas = Color(red: 255/255, green: 251/255, blue: 245/255)

    /// 카드처럼 바탕 위에 떠 있는 면.
    public static let surface = Color.white

    /// 본문 텍스트. 순검정은 밝은 배경에서 너무 딱딱해 따뜻한 먹색을 쓴다.
    public static let ink = Color(red: 43/255, green: 37/255, blue: 32/255)

    /// 보조 텍스트.
    public static let inkMuted = Color(red: 141/255, green: 130/255, blue: 119/255)

    /// 구분선, 비활성 테두리.
    public static let line = Color(red: 234/255, green: 226/255, blue: 215/255)

    public static let white = Color.white
    public static let clear = Color.clear

    // MARK: - 브랜드

    public static let brand = DesignPalette(
        main: Color(red: 255/255, green: 122/255, blue: 41/255),
        deep: Color(red: 214/255, green: 88/255, blue: 12/255),
        soft: Color(red: 255/255, green: 237/255, blue: 224/255)
    )

    // MARK: - 종목

    /// 푸시업.
    public static let push = brand

    /// 풀업.
    public static let pull = DesignPalette(
        main: Color(red: 45/255, green: 140/255, blue: 255/255),
        deep: Color(red: 22/255, green: 100/255, blue: 202/255),
        soft: Color(red: 226/255, green: 240/255, blue: 255/255)
    )

    /// 스쿼트.
    public static let squat = DesignPalette(
        main: Color(red: 46/255, green: 196/255, blue: 122/255),
        deep: Color(red: 22/255, green: 150/255, blue: 88/255),
        soft: Color(red: 226/255, green: 249/255, blue: 237/255)
    )

    /// 러닝. 아직 화면은 없지만 팔레트는 미리 잡아둔다.
    public static let run = DesignPalette(
        main: Color(red: 155/255, green: 89/255, blue: 246/255),
        deep: Color(red: 116/255, green: 52/255, blue: 204/255),
        soft: Color(red: 241/255, green: 234/255, blue: 255/255)
    )

    // MARK: - 상태

    public static let success = DesignPalette(
        main: Color(red: 88/255, green: 196/255, blue: 62/255),
        deep: Color(red: 58/255, green: 152/255, blue: 36/255),
        soft: Color(red: 232/255, green: 249/255, blue: 226/255)
    )

    public static let sunny = DesignPalette(
        main: Color(red: 255/255, green: 194/255, blue: 41/255),
        deep: Color(red: 214/255, green: 150/255, blue: 12/255),
        soft: Color(red: 255/255, green: 246/255, blue: 224/255)
    )

    // MARK: - 외부 브랜드
    //
    // 소셜 로그인 버튼은 각 서비스의 브랜드 가이드를 따라야 해서
    // 앱 팔레트와 별도로 둔다.

    public static let kakao = DesignPalette(
        main: Color(red: 254/255, green: 229/255, blue: 0/255),
        deep: Color(red: 209/255, green: 188/255, blue: 0/255),
        soft: Color(red: 255/255, green: 250/255, blue: 214/255)
    )

    public static let apple = DesignPalette(
        main: Color(red: 43/255, green: 39/255, blue: 35/255),
        deep: Color(red: 12/255, green: 10/255, blue: 9/255),
        soft: Color(red: 238/255, green: 235/255, blue: 231/255)
    )

    /// 카카오 버튼 위에 얹는 글자색. 노란 배경에는 어두운 글자만 허용된다.
    public static let kakaoLabel = Color(red: 24/255, green: 22/255, blue: 20/255)

    /// 비활성 · 준비 중.
    public static let muted = DesignPalette(
        main: Color(red: 189/255, green: 179/255, blue: 168/255),
        deep: Color(red: 154/255, green: 144/255, blue: 133/255),
        soft: Color(red: 245/255, green: 240/255, blue: 233/255)
    )
}
