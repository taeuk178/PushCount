import Foundation

/// 캐릭터의 표정과 몸짓 상태.
public enum CharacterMood: Sendable, Equatable {

    /// 대기. 숨 쉬듯 천천히 위아래로 움직인다.
    case resting

    /// 운동 중. 들어온 위상값을 그대로 따라 움직인다.
    case working

    /// 자세가 감지 범위를 벗어남. 표정으로만 알린다.
    case confused

    /// 완료. 팔을 들고 좋아한다.
    case cheering

    /// 위상값을 바깥에서 받아야 하는 상태인지.
    ///
    /// `false` 면 캐릭터가 스스로 움직인다.
    var followsExternalPhase: Bool {
        self == .working
    }
}
