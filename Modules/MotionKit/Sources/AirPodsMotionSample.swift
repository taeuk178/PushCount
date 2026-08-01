//
//  AirPodsMotionSample.swift
//  MotionKit
//
//  Created by taeuk on 8/1/26.
//

import CoreMotion
import Foundation
import simd

/// 에어팟에서 들어온 모션 샘플 한 건.
///
/// `CMDeviceMotion` 은 참조 타입이라 그대로 뷰에 넘기면 비교/스냅샷이 어렵다.
/// 화면에 필요한 값만 뽑아 Sendable 값 타입으로 고정한다.
public struct AirPodsMotionSample: Equatable, Sendable {

    /// 기기 부팅 이후 경과 시간(초).
    public let timestamp: TimeInterval

    /// 고개 끄덕임. 푸시업의 상하 움직임이 여기에 가장 크게 실린다. (도)
    public let pitch: Double

    /// 고개 기울임. (도)
    public let roll: Double

    /// 고개 돌림. (도)
    public let yaw: Double

    /// 중력을 제외한 사용자 가속도. (G)
    public let userAcceleration: SIMD3<Double>

    /// 자이로 회전 속도. (rad/s)
    public let rotationRate: SIMD3<Double>

    /// 기기 좌표계에서 본 중력 방향. (G)
    public let gravity: SIMD3<Double>

    public init(motion: CMDeviceMotion) {
        self.timestamp = motion.timestamp
        self.pitch = motion.attitude.pitch * 180 / .pi
        self.roll = motion.attitude.roll * 180 / .pi
        self.yaw = motion.attitude.yaw * 180 / .pi
        self.userAcceleration = SIMD3(
            motion.userAcceleration.x,
            motion.userAcceleration.y,
            motion.userAcceleration.z
        )
        self.rotationRate = SIMD3(
            motion.rotationRate.x,
            motion.rotationRate.y,
            motion.rotationRate.z
        )
        self.gravity = SIMD3(motion.gravity.x, motion.gravity.y, motion.gravity.z)
    }

    /// 중력 축에 투영한 사용자 가속도.
    ///
    /// 머리가 어느 방향을 보고 있든 "위아래로 얼마나 움직였는가"를 하나의
    /// 스칼라로 만들어 준다. 푸시업 rep 감지의 1차 신호로 쓸 값이다.
    public var verticalAcceleration: Double {
        let gravityLength = simd_length(gravity)
        guard gravityLength > .ulpOfOne else { return 0 }
        return simd_dot(userAcceleration, gravity / gravityLength)
    }

    /// 사용자 가속도의 크기. (G)
    public var accelerationMagnitude: Double {
        simd_length(userAcceleration)
    }
}
