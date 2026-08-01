import Foundation
import DesignSystemKit

/// 홈에서 고를 수 있는 운동 종목.
///
/// `isAvailable` 이 `false` 인 종목은 아직 감지 로직이 없다. 카드를 감추는 대신
/// 잠금 상태로 남겨 무엇이 준비 중인지 그대로 보여준다.
struct Exercise: Identifiable {

    let id: String
    let name: String
    let detail: String
    let icon: String
    let palette: DesignPalette
    let cheer: String
    let targetCount: Int
    let isAvailable: Bool

    static let pushUp = Exercise(
        id: "pushUp",
        name: "푸시업",
        detail: "가슴 · 삼두",
        icon: "figure.strengthtraining.traditional",
        palette: DesignColor.push,
        cheer: "같이 해봐요!",
        targetCount: 50,
        isAvailable: true
    )

    static let pullUp = Exercise(
        id: "pullUp",
        name: "풀업",
        detail: "등 · 이두",
        icon: "figure.play",
        palette: DesignColor.pull,
        cheer: "곧 만나요",
        targetCount: 20,
        isAvailable: false
    )

    static let squat = Exercise(
        id: "squat",
        name: "스쿼트",
        detail: "하체 · 둔근",
        icon: "figure.cross.training",
        palette: DesignColor.squat,
        cheer: "곧 만나요",
        targetCount: 60,
        isAvailable: false
    )

    static let all: [Exercise] = [.pushUp, .pullUp, .squat]
}
