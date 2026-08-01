//
//  PushUpRepDetector.swift
//  MotionKit
//
//  Created by taeuk on 8/1/26.
//

import Foundation

/// 에어팟 모션 신호에서 푸시업 반복을 세는 검출기.
///
/// ## 확정 규칙 (2026-08-01)
///
/// - **top-to-top**: 검증된 상단에서 시작해 하강 → 상승 복귀를 모두 관찰한 경우에만 센다.
///   상단 확인 전에는 절대 세지 않으므로 세트 첫 동작이 검증에 소모될 수 있다.
/// - **10% 하단 / 85% 카운트 / 90% rearm**: 하단까지 내려갔다가 85% 복귀 시 1회.
///   카운트 후 90% 재무장 전에는 다음 반복을 받지 않는다 ("절반 반복 연타" 차단).
/// - **3초 이내** (하강 시작 기준, 최하단 정지 시간 포함). 바닥에서 쉬면 거부되는
///   것이 의도된 동작이다. 통제 템포(2:0:2, 약 4초/회)도 의도적으로 거부된다.
///
/// ## 실기기 튜닝 이력 (2026-08-01, AirPods + iPhone)
///
/// - rearm 0.95 → 0.90: 창 진폭이 가장 강한 반복 기준으로 커지면 이후 반복의
///   상단 스파이크(0.93)가 0.95 에 못 미쳐 통째로 유실됐다.
/// - topExit 0.80 → 0.70: countThreshold(0.85)와 간격이 좁으면 상단 잡음
///   (0.79→0.86)이 가짜 하강 → 가짜 거부를 만들었다.
/// - travel 0.20 → 0.10: 신호 예열 중인 세트 첫 회가 0.11m 로 과소평가돼 유실됐다.
/// - 검증 결과: 정상 5회 → 5회 카운트. 자세 잡는 흔들림(tooFast), 얕은 움직임
///   (travel 0.04), 바닥 휴식(tooSlow) 모두 정상 거부.
///
/// ## 신호
///
/// 1차 신호는 중력축에 투영한 사용자 가속도다. 푸시업에서 머리가 반드시 하는
/// 운동은 위아래 병진이고, 고개를 고정한 채 해도 가속도에는 반드시 나타난다.
/// 피치는 절대 자세 판정(엎드려 있는가)에만 쓴다.
///
/// 단순조화운동에서 가속도는 변위와 역위상·동주파수라 반복당 정확히 한 주기다.
/// `verticalAcceleration` 은 중력 방향(+아래)이므로 **맨 위 근처에서 최대,
/// 맨 아래 근처에서 최소**가 되고, 최솟값 0 정규화 위상에서 1 이 맨 위다.
///
/// ## Phase 1 근사
///
/// ROM% 는 최근 8초 min/max 정규화 위상으로 근사한다(개인 보정 미구현).
/// 얕은 동작이 위상을 통과하는 약점은 이동거리 게이트로 방어한다.
/// 개인별 보정(referenceTravel)과 제약 적분 기반의 진짜 ROM 은 Phase 2 로 보류.
public struct PushUpRepDetector {

    // MARK: - State machine

    /// 반복 검출 상태 머신. ascending 은 bottomReached 안에서
    /// 카운트 문턱 도달로 판정하므로 별도 상태로 두지 않는다.
    public enum RepState: Equatable, Sendable {

        /// 신호가 잡음 수준이라 추적하지 않음.
        case idle

        /// 상단(rearm 문턱) 확인 대기. 여기서는 절대 세지 않는다.
        case waitingForTop

        /// 상단 확인됨. 하강 시작 대기.
        case ready

        /// 하강 중. 시각은 수행 시간 측정 기준점.
        case descending(startedAt: TimeInterval)

        /// 10% 하단 도달. 상승해서 카운트 문턱을 넘기를 기다린다.
        case bottomReached(startedAt: TimeInterval)

        /// 카운트 또는 거부 직후. rearm 문턱(90%) 재도달 전에는 다음 반복을 받지 않는다.
        case waitingForRearm

        public var label: String {
            switch self {
            case .idle: "idle"
            case .waitingForTop: "waitingForTop"
            case .ready: "ready"
            case .descending: "descending"
            case .bottomReached: "bottomReached"
            case .waitingForRearm: "waitingForRearm"
            }
        }
    }

    /// 반복 후보가 거부된 이유. 디버그 로그와 진단 UI 용.
    public enum RejectionReason: String, Sendable {
        case notDeepEnough      // 10% 하단에 도달하지 못하고 올라옴
        case tooFast            // 0.6초 미만
        case tooSlow            // 3초 초과
        case insufficientTravel // 역산한 머리 이동거리 부족
        case invalidPosture     // 사이클 내 자세 유효 비율 미달
    }

    // MARK: - Configuration

    public struct Configuration: Equatable, Sendable {

        /// 저역통과 차단 주파수(Hz).
        /// 담당: 잡음 제거. 푸시업 대역(0.17~1.7Hz) 위의 떨림을 걸러낸다.
        /// 낮추면 파형이 매끈해지지만 반응이 느려진다.
        public var lowPassCutoff: Double = 3.0

        /// 위상 정규화 관찰 창(초). 반복 2~4회 분량.
        /// 담당: 위상 0~1 의 기준 범위. 이 창의 가속도 min/max 가 0 과 1 이 된다.
        /// 길수록 기준이 안정적이지만 강도 변화(피로)에 늦게 적응한다.
        public var envelopeWindow: TimeInterval = 8.0

        /// 위상 정규화를 시작할 최소 가속도 진폭(G).
        /// 담당: 추적 시작 스위치. 창 진폭이 이보다 작으면 잡음뿐이라 보고
        /// 아예 추적하지 않는다 (정지 상태 잡음이 0~1 로 증폭되는 것을 방지).
        /// 깊이 기준이 아니다 — 깊이는 minVerticalTravel 담당.
        public var minSignalAmplitude: Double = 0.03

        /// 유효한 하단 도달 기준 (위상, 0=맨 아래).
        /// 담당: "충분히 내려갔는가". 가동범위의 90% 지점까지 내려가야 하단으로
        /// 인정한다. 여기 못 닿고 올라오면 notDeepEnough 거부.
        public var bottomThreshold: Double = 0.10

        /// 카운트 지점 (위상, 1=맨 위).
        /// 담당: "충분히 올라왔는가". 하단 도달 후 여기까지 복귀한 그 샘플에서
        /// 1회를 확정한다 (시간·이동거리·자세 검증 통과 시).
        public var countThreshold: Double = 0.85

        /// 하강 시작 인정 지점 (위상).
        /// 담당: 수행 시간 타이머의 시작점. ready 상태에서 이 아래로 내려가는
        /// 순간부터 3초 카운트다운이 돈다.
        /// countThreshold(0.85)와의 간격이 상단 잡음 방어벽 — 실기기에서 0.80
        /// 으로 두면 잡음(0.79→0.86)이 가짜 하강→가짜 거부를 만들었다.
        public var topExitThreshold: Double = 0.70

        /// 재무장 문턱 (위상). 최초 상단 확인에도 같은 값을 쓴다.
        /// 담당: top-to-top 보장. 카운트/거부 후 여기까지 올라와야 다음 반복이
        /// 활성화된다. 85%까지만 갔다 다시 내려가는 "절반 반복 연타"를 차단.
        /// 실기기에서 0.95 는 과했다 — 이후 반복의 상단 스파이크(0.93)가 못
        /// 미쳐 통째로 유실됐다.
        public var rearmThreshold: Double = 0.90

        /// 1회 최소 수행 시간(초). 하강 시작 기준.
        /// 담당: 자세 잡을 때의 빠른 흔들림 차단 (실측 0.2~0.3초짜리 잡동작 거부).
        public var minRepDuration: TimeInterval = 0.60

        /// 1회 최대 수행 시간(초). 하강 시작 기준. 최하단 정지 시간 포함.
        /// 담당: "3초 이내 수행" 규칙. 바닥에서 쉬면 거부되는 것이 의도된 동작.
        /// 통제 템포(2:0:2, 약 4초/회)도 의도적으로 거부된다.
        public var maxRepDuration: TimeInterval = 3.00

        /// 반복으로 인정할 최소 머리 이동거리(m). 추정기 스케일 기준 값이다.
        ///
        /// 단순조화운동 역산은 실기기에서 정상 반복을 0.5m 안팎으로 (실제의
        /// 약 2배) 과대평가하고, 신호 예열 중인 세트 첫 회는 주기가 짧게 잡혀
        /// 0.11m 수준으로 과소평가한다. 물리적 의미의 미터가 아니라 이 추정기
        /// 스케일에서의 컷이므로, 실측 분포(정상 0.5±, 얕은 굽힘 0.04 미만)
        /// 사이에 둔다.
        public var minVerticalTravel: Double = 0.10

        /// 사이클 내 자세 유효 샘플 비율 하한.
        /// 담당: 반복 도중 자세 이탈 판정. 단일 샘플 스파이크로 무효화하지 않고
        /// 사이클의 90% 이상이 자세 범위 안이면 통과시킨다.
        public var minPostureValidRatio: Double = 0.90

        /// 푸시업 자세로 인정할 절대 피치 범위(도). `nil` 이면 자세를 보지 않는다.
        /// 담당: "엎드려 있는가". 앉아서 숙이기·서서 절하기·누워서 움직이기처럼
        /// 이동거리는 통과하는 비푸시업 동작을 절대 자세로 차단한다.
        /// 반복 중 각도가 변할 필요는 없다 — 범위 안에 머물기만 하면 된다.
        /// 실측: 정상 푸시업에서 -33°~-59° 관측. 피로 시 -29° 까지 올라옴.
        public var posturePitchRange: ClosedRange<Double>? = -90 ... -20

        /// 이 시간 이상 샘플이 끊기면 상태를 초기화한다(초).
        /// 담당: 에어팟 신호 끊김 방어. 끊김 전후 샘플을 이어 붙여 엉뚱한
        /// 반복을 만들지 않도록 상태 머신을 idle 로 되돌린다.
        public var maxSampleGap: TimeInterval = 1.0

        public init() {}
    }

    // MARK: - Result

    public struct Result: Equatable, Sendable {

        /// 이번 샘플에서 반복 1회가 완성되었는가.
        public let didCompleteRep: Bool

        /// 신호 위상. 0 이 맨 아래, 1 이 맨 위. (실제 ROM 이 아니라 근사값)
        public let phase: Double

        /// 최근 관찰 창의 가속도 진폭(G).
        public let signalAmplitude: Double

        /// 추적 중인가.
        public let isTracking: Bool

        /// 현재 샘플의 자세가 범위 안인가.
        public let isPostureValid: Bool

        /// 상태 머신 현재 상태.
        public let state: RepState

        /// 이번 샘플에서 반복 후보가 거부되었다면 그 사유.
        public let rejection: RejectionReason?

        /// 카운트 또는 거부 시점의 수행 시간(하강 시작 기준).
        public let repDuration: TimeInterval?

        /// 카운트 또는 거부 시점의 추정 이동거리(m).
        public let estimatedTravel: Double?
    }

    // MARK: - State

    public private(set) var repCount: Int = 0

    public private(set) var state: RepState = .idle

    public var configuration: Configuration

    private var smoothedPitch: Double?
    private var smoothedAcceleration: Double?
    private var lastTimestamp: TimeInterval?
    private var window: [(time: TimeInterval, value: Double)] = []

    // 사이클(하강 시작 → 카운트) 동안의 누적값
    private var cycleMinAcceleration: Double = 0
    private var cycleMaxAcceleration: Double = 0
    private var cyclePostureValidCount: Int = 0
    private var cycleSampleCount: Int = 0

    public init(configuration: Configuration = Configuration()) {
        self.configuration = configuration
    }

    // MARK: - Input

    @discardableResult
    public mutating func process(sample: AirPodsMotionSample) -> Result {
        process(
            pitchDegrees: sample.pitch,
            verticalAcceleration: sample.verticalAcceleration,
            timestamp: sample.timestamp
        )
    }

    /// 센서 타입에 의존하지 않는 진입점.
    @discardableResult
    public mutating func process(
        pitchDegrees: Double,
        verticalAcceleration: Double,
        timestamp: TimeInterval
    ) -> Result {
        guard let previousTimestamp = lastTimestamp else {
            resetSignalState(pitch: pitchDegrees, acceleration: verticalAcceleration, timestamp: timestamp)
            return makeResult(phase: 0.5, amplitude: 0, postureValid: true)
        }

        let dt = timestamp - previousTimestamp
        guard dt > 0, dt <= configuration.maxSampleGap else {
            // 시간이 역행하거나 흐름이 끊긴 구간은 이어 붙이지 않는다.
            resetSignalState(pitch: pitchDegrees, acceleration: verticalAcceleration, timestamp: timestamp)
            return makeResult(phase: 0.5, amplitude: 0, postureValid: true)
        }
        lastTimestamp = timestamp

        let accel = lowPassed(verticalAcceleration, previous: smoothedAcceleration, dt: dt)
        smoothedAcceleration = accel

        let pitch = lowPassed(pitchDegrees, previous: smoothedPitch, dt: dt)
        smoothedPitch = pitch

        appendToWindow(value: accel, at: timestamp)

        let postureValid = isWithinPostureRange(pitch)

        let (minValue, maxValue) = windowBounds()
        let amplitude = maxValue - minValue

        guard amplitude >= configuration.minSignalAmplitude else {
            // 신호가 잡음 수준. 정규화하면 잡음이 0…1 로 증폭되므로 추적을 멈춘다.
            state = .idle
            return makeResult(phase: 0.5, amplitude: amplitude, postureValid: postureValid)
        }

        let phase = (accel - minValue) / amplitude

        // 사이클 진행 중이면 이번 샘플을 누적한다.
        if isInCycle {
            cycleMinAcceleration = Swift.min(cycleMinAcceleration, accel)
            cycleMaxAcceleration = Swift.max(cycleMaxAcceleration, accel)
            cycleSampleCount += 1
            if postureValid { cyclePostureValidCount += 1 }
        }

        let outcome = advance(phase: phase, acceleration: accel, postureValid: postureValid, timestamp: timestamp)

        return Result(
            didCompleteRep: outcome.counted,
            phase: phase,
            signalAmplitude: amplitude,
            isTracking: true,
            isPostureValid: postureValid,
            state: state,
            rejection: outcome.rejection,
            repDuration: outcome.duration,
            estimatedTravel: outcome.travel
        )
    }

    public mutating func reset() {
        repCount = 0
        smoothedPitch = nil
        smoothedAcceleration = nil
        lastTimestamp = nil
        window.removeAll(keepingCapacity: true)
        state = .idle
        clearCycle()
    }
}

// MARK: - Internals

private extension PushUpRepDetector {

    var isInCycle: Bool {
        switch state {
        case .descending, .bottomReached: true
        default: false
        }
    }

    /// 상태 머신 한 스텝.
    ///
    /// idle 에서는 신호가 살아나는 즉시 waitingForTop 으로 올라가고,
    /// 상단 확인(rearm 문턱) 전에는 어떤 반복도 세지 않는다. 그래서 신호가
    /// 막 잡히기 시작한 세트 첫 동작은 상단 검증에 소모될 수 있다.
    mutating func advance(
        phase: Double,
        acceleration: Double,
        postureValid: Bool,
        timestamp: TimeInterval
    ) -> (counted: Bool, rejection: RejectionReason?, duration: TimeInterval?, travel: Double?) {

        if case .idle = state {
            state = .waitingForTop
        }

        switch state {
        case .idle:
            break

        case .waitingForTop:
            if phase >= configuration.rearmThreshold, postureValid {
                state = .ready
            }

        case .ready:
            if phase <= configuration.topExitThreshold {
                state = .descending(startedAt: timestamp)
                seedCycle(acceleration: acceleration, postureValid: postureValid)
            }

        case .descending(let startedAt):
            let elapsed = timestamp - startedAt
            if elapsed > configuration.maxRepDuration {
                state = .waitingForRearm
                return (false, .tooSlow, elapsed, nil)
            }
            if phase <= configuration.bottomThreshold {
                state = .bottomReached(startedAt: startedAt)
            } else if phase >= configuration.countThreshold {
                // 하단에 못 미치고 올라옴 = 부분 반복.
                state = .waitingForRearm
                return (false, .notDeepEnough, elapsed, nil)
            }

        case .bottomReached(let startedAt):
            let elapsed = timestamp - startedAt
            if elapsed > configuration.maxRepDuration {
                state = .waitingForRearm
                return (false, .tooSlow, elapsed, nil)
            }
            if phase >= configuration.countThreshold {
                state = .waitingForRearm
                let travel = estimatedTravel(duration: elapsed)

                if elapsed < configuration.minRepDuration {
                    return (false, .tooFast, elapsed, travel)
                }
                if postureValidRatio < configuration.minPostureValidRatio {
                    return (false, .invalidPosture, elapsed, travel)
                }
                if travel < configuration.minVerticalTravel {
                    return (false, .insufficientTravel, elapsed, travel)
                }

                repCount += 1
                return (true, nil, elapsed, travel)
            }

        case .waitingForRearm:
            if phase >= configuration.rearmThreshold {
                state = .ready
            }
        }

        return (false, nil, nil, nil)
    }

    var postureValidRatio: Double {
        guard cycleSampleCount > 0 else { return 1 }
        return Double(cyclePostureValidCount) / Double(cycleSampleCount)
    }

    /// 사이클을 단순조화운동으로 보고 가속도 최대-최소에서 이동거리를 역산한다.
    /// `a_peak = A * ω²` 이므로 왕복 이동거리는 `(최대-최소) * 9.81 / ω²`.
    func estimatedTravel(duration: TimeInterval) -> Double {
        guard duration > 0, cycleMaxAcceleration > cycleMinAcceleration else { return 0 }
        let peakToPeak = (cycleMaxAcceleration - cycleMinAcceleration) * 9.81
        let omega = 2 * .pi / duration
        return peakToPeak / (omega * omega)
    }

    mutating func seedCycle(acceleration: Double, postureValid: Bool) {
        cycleMinAcceleration = acceleration
        cycleMaxAcceleration = acceleration
        cycleSampleCount = 1
        cyclePostureValidCount = postureValid ? 1 : 0
    }

    mutating func clearCycle() {
        cycleMinAcceleration = 0
        cycleMaxAcceleration = 0
        cycleSampleCount = 0
        cyclePostureValidCount = 0
    }

    func makeResult(phase: Double, amplitude: Double, postureValid: Bool) -> Result {
        Result(
            didCompleteRep: false,
            phase: phase,
            signalAmplitude: amplitude,
            isTracking: false,
            isPostureValid: postureValid,
            state: state,
            rejection: nil,
            repDuration: nil,
            estimatedTravel: nil
        )
    }

    /// 1차 저역통과. 샘플 간격이 흔들려도 차단 주파수가 유지되도록 dt 로 계수를 만든다.
    func lowPassed(_ value: Double, previous: Double?, dt: TimeInterval) -> Double {
        guard let previous else { return value }
        let tau = 1 / (2 * .pi * configuration.lowPassCutoff)
        let alpha = dt / (tau + dt)
        return previous + alpha * (value - previous)
    }

    mutating func appendToWindow(value: Double, at timestamp: TimeInterval) {
        window.append((time: timestamp, value: value))

        let cutoff = timestamp - configuration.envelopeWindow
        if let firstValid = window.firstIndex(where: { $0.time >= cutoff }), firstValid > 0 {
            window.removeFirst(firstValid)
        }
    }

    func isWithinPostureRange(_ pitch: Double) -> Bool {
        guard let range = configuration.posturePitchRange else { return true }
        return range.contains(pitch)
    }

    func windowBounds() -> (min: Double, max: Double) {
        var minValue = Double.greatestFiniteMagnitude
        var maxValue = -Double.greatestFiniteMagnitude
        for entry in window {
            minValue = Swift.min(minValue, entry.value)
            maxValue = Swift.max(maxValue, entry.value)
        }
        return (minValue, maxValue)
    }

    mutating func resetSignalState(pitch: Double, acceleration: Double, timestamp: TimeInterval) {
        smoothedPitch = pitch
        smoothedAcceleration = acceleration
        lastTimestamp = timestamp
        window = [(time: timestamp, value: acceleration)]
        state = .idle
        clearCycle()
    }
}
