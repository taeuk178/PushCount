//
//  PushUpCounter.swift
//  MotionKit
//
//  Created by taeuk on 8/1/26.
//

import Foundation

/// `AirPodsMotionMonitor` 의 모션 흐름을 `PushUpRepDetector` 에 연결해
/// 화면이 관찰할 수 있는 상태로 바꿔주는 어댑터.
///
/// 디버그 로그는 `[PUSHUP]` 접두사로 통일한다. Xcode 콘솔에서 필터링할 것.
@MainActor
@Observable
public final class PushUpCounter {

    /// 위상 표시 갱신 주기. 모션은 25Hz 로 들어오지만 UI 는 그럴 필요가 없다.
    /// 횟수는 이 주기와 무관하게 즉시 반영된다.
    private static let publishInterval: TimeInterval = 1.0 / 12.0

    /// 디버그 상태 라인 출력 주기.
    private static let logInterval: TimeInterval = 1.0

    private static let logPrefix = "[PUSHUP]"

    /// 자동으로 감지한 반복 횟수.
    public private(set) var repCount = 0

    /// 신호 위상. 0 이 맨 아래, 1 이 맨 위.
    public private(set) var phase: Double = 0.5

    /// 최근 관찰 창에서 추정한 가속도 진폭(G).
    public private(set) var signalAmplitude: Double = 0

    /// 반복으로 볼 만한 주기 신호를 잡고 있는가.
    public private(set) var isTracking = false

    /// 머리 자세가 푸시업 자세 범위 안에 있는가.
    public private(set) var isPostureValid = false

    /// 상태 머신 현재 상태 라벨. 진단 UI 용.
    public private(set) var stateLabel = "idle"

    /// 마지막 거부 사유. 진단 UI 용.
    public private(set) var lastRejection: PushUpRepDetector.RejectionReason?

    /// 일시정지 중에는 샘플을 버린다. 신호 연속성이 끊기므로
    /// 재개 시 검출기 내부 상태도 함께 초기화된다.
    public var isPaused = false {
        didSet {
            guard isPaused != oldValue else { return }
            log(isPaused ? "일시정지" : "재개")
            guard !isPaused else { return }
            detector.reset()
            restoreRepCount()
        }
    }

    @ObservationIgnored private var detector = PushUpRepDetector()
    @ObservationIgnored private weak var monitor: AirPodsMotionMonitor?
    @ObservationIgnored private var lastPublishedAt: Date?
    @ObservationIgnored private var lastLoggedAt: Date?
    @ObservationIgnored private var lastLoggedState = "idle"

    /// `detector.reset()` 은 내부 카운트도 0 으로 돌리므로,
    /// 화면에 누적된 횟수는 따로 들고 있다가 되살린다.
    @ObservationIgnored private var carriedRepCount = 0

    public init(configuration: PushUpRepDetector.Configuration = .init()) {
        detector = PushUpRepDetector(configuration: configuration)
    }

    // MARK: - 연결

    public func attach(to monitor: AirPodsMotionMonitor) {
        self.monitor = monitor
        monitor.onDeviceMotion = { [weak self] sample in
            self?.ingest(sample)
        }
        log("측정 시작 (모니터 연결)")
    }

    public func detach() {
        monitor?.onDeviceMotion = nil
        monitor = nil
        log("측정 종료 (모니터 해제) — 최종 횟수 \(repCount)회")
    }

    public func reset() {
        detector.reset()
        carriedRepCount = 0
        repCount = 0
        phase = 0.5
        signalAmplitude = 0
        isTracking = false
        isPostureValid = false
        stateLabel = "idle"
        lastRejection = nil
        lastPublishedAt = nil
        lastLoggedAt = nil
        lastLoggedState = "idle"
        log("카운터 리셋")
    }

    // MARK: - 처리

    private func ingest(_ sample: AirPodsMotionSample) {
        guard !isPaused else { return }

        let result = detector.process(sample: sample)

        logEvents(result: result, sample: sample)

        if result.didCompleteRep {
            repCount = carriedRepCount + detector.repCount
        }

        let now = Date()
        if let lastPublishedAt, now.timeIntervalSince(lastPublishedAt) < Self.publishInterval {
            return
        }
        lastPublishedAt = now
        phase = result.phase
        signalAmplitude = result.signalAmplitude
        isTracking = result.isTracking
        isPostureValid = result.isPostureValid
        stateLabel = result.state.label
        if let rejection = result.rejection {
            lastRejection = rejection
        }
    }

    private func restoreRepCount() {
        carriedRepCount = repCount
    }

    // MARK: - 로깅

    private func logEvents(result: PushUpRepDetector.Result, sample: AirPodsMotionSample) {
        // 상태 전이
        let newState = result.state.label
        if newState != lastLoggedState {
            log(String(format: "상태 %@ → %@ (phase %.2f)", lastLoggedState, newState, result.phase))
            lastLoggedState = newState
        }

        // 카운트 성공
        if result.didCompleteRep {
            log(String(
                format: "✅ 1회 카운트 — 누적 %d회, 수행 %.2f초, 추정 이동거리 %.2fm",
                carriedRepCount + detector.repCount,
                result.repDuration ?? 0,
                result.estimatedTravel ?? 0
            ))
        }

        // 거부
        if let rejection = result.rejection {
            log(String(
                format: "❌ 반복 거부 — %@ (수행 %.2f초, 이동거리 %@)",
                describe(rejection),
                result.repDuration ?? 0,
                result.estimatedTravel.map { String(format: "%.2fm", $0) } ?? "-"
            ))
        }

        // 1초 주기 상태 라인
        let now = Date()
        if lastLoggedAt.map({ now.timeIntervalSince($0) >= Self.logInterval }) ?? true {
            lastLoggedAt = now
            log(String(
                format: "phase %.2f | 고개 %.0f° | 상하 %+.3fG | 진폭 %.3fG | 횟수 %d | %@%@",
                result.phase,
                sample.pitch,
                sample.verticalAcceleration,
                result.signalAmplitude,
                carriedRepCount + detector.repCount,
                newState,
                result.isPostureValid ? "" : " | 자세이탈"
            ))
        }
    }

    private func describe(_ reason: PushUpRepDetector.RejectionReason) -> String {
        switch reason {
        case .notDeepEnough: "10% 하단 미도달"
        case .tooFast: "0.6초 미만"
        case .tooSlow: "3초 초과"
        case .insufficientTravel: "이동거리 부족"
        case .invalidPosture: "자세 유효 비율 미달"
        }
    }

    private func log(_ message: String) {
        print("\(Self.logPrefix) \(message)")
    }
}
