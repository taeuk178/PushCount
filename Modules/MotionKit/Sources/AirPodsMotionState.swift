//
//  AirPodsMotionState.swift
//  MotionKit
//
//  Created by taeuk on 8/1/26.
//

import Foundation

/// 에어팟 모션 센서의 현재 가용 상태.
///
/// 운동 감지는 `.worn` 일 때만 가능하다. 나머지 상태는 사용자에게 무엇을
/// 해결해야 하는지 그대로 안내할 수 있도록 원인별로 분리했다.
public enum AirPodsMotionState: Equatable, Sendable {

    /// 모션 센서를 지원하지 않는 기기 또는 헤드폰.
    case unsupported

    /// 모션 권한이 거부되었거나 제한됨. 설정 앱에서만 되돌릴 수 있다.
    case unauthorized

    /// 모션 지원 에어팟이 연결되어 있지 않음.
    case disconnected

    /// 연결은 되었지만 모션 데이터가 들어오지 않음 = 귀에서 뺀 상태.
    case notWorn

    /// 착용 확인. 모션 데이터가 흐르고 있다.
    case worn

    /// 운동 감지를 시작할 수 있는 상태인지.
    public var isReadyForWorkout: Bool {
        self == .worn
    }
}

public extension AirPodsMotionState {

    var title: String {
        switch self {
        case .unsupported: "모션 미지원 기기"
        case .unauthorized: "동작 및 피트니스 권한 필요"
        case .disconnected: "에어팟이 연결되지 않았습니다"
        case .notWorn: "에어팟을 착용해 주세요"
        case .worn: "에어팟 착용 완료"
        }
    }

    var message: String {
        switch self {
        case .unsupported: "AirPods Pro 이상에서 동작 감지를 사용할 수 있어요"
        case .unauthorized: "설정 > 개인정보 보호에서 동작 권한을 허용해 주세요"
        case .disconnected: "에어팟을 연결하면 자동으로 횟수를 세드려요"
        case .notWorn: "양쪽 모두 착용하면 감지가 시작돼요"
        case .worn: "이제 자동으로 횟수를 셀 수 있어요"
        }
    }

    var systemImageName: String {
        switch self {
        case .unsupported: "exclamationmark.triangle.fill"
        case .unauthorized: "hand.raised.fill"
        case .disconnected: "airpods.gen3"
        case .notWorn: "airpods.gen3"
        case .worn: "checkmark.circle.fill"
        }
    }
}
