//
//  AirPodsMotionMonitor.swift
//  MotionKit
//
//  Created by taeuk on 8/1/26.
//

import CoreMotion
import Foundation

/// 에어팟 모션 센서의 연결/착용 상태를 관찰한다.
///
/// 착용 여부를 직접 알려주는 API 는 없기 때문에 두 신호를 합쳐서 판단한다.
/// - `CMHeadphoneMotionManagerDelegate`: 모션 지원 헤드폰의 연결/해제
/// - device motion 샘플의 흐름: 에어팟은 귀에서 빼면 모션 전송을 멈춘다
///
/// `Info.plist` 에 `NSMotionUsageDescription` 이 없으면 업데이트 시작 시점에
/// 앱이 종료되므로 주의한다.
@MainActor
@Observable
public final class AirPodsMotionMonitor {

    /// 마지막 샘플 이후 이 시간이 지나면 귀에서 뺀 것으로 간주한다.
    /// 헤드폰 모션은 25Hz 내외로 들어오므로 여유를 둔 값이다.
    private static let wearTimeout: TimeInterval = 1.5

    /// 시작 직후에는 연결 콜백을 기다려야 하므로, 이 시간이 지나기 전에는
    /// `.unsupported` 로 단정하지 않는다.
    private static let unsupportedGrace: TimeInterval = 2.0

    private static let evaluateInterval: Duration = .milliseconds(300)

    /// 화면 갱신 주기. 모션은 25Hz 내외로 들어오지만 숫자 표시를 그 속도로
    /// 리렌더할 이유가 없어 12Hz 정도로 낮춘다.
    private static let publishInterval: TimeInterval = 1.0 / 12.0

    public private(set) var state: AirPodsMotionState = .disconnected

    /// UI 표시용 최신 샘플. 위 주기로 솎아서 갱신된다.
    public private(set) var latestSample: AirPodsMotionSample?

    /// 착용 중 들어오는 모션 샘플. 솎아내지 않은 전체 흐름(25Hz 내외)이며,
    /// 푸시업 감지 파이프라인이 여기에 붙는다.
    @ObservationIgnored
    public var onDeviceMotion: (@MainActor (AirPodsMotionSample) -> Void)?

    @ObservationIgnored private var lastPublishedAt: Date?

    @ObservationIgnored private let manager = CMHeadphoneMotionManager()
    @ObservationIgnored private let delegateProxy = HeadphoneMotionDelegateProxy()
    @ObservationIgnored private var isMonitoring = false
    @ObservationIgnored private var isConnected = false
    @ObservationIgnored private var startedAt: Date?
    @ObservationIgnored private var lastSampleAt: Date?
    @ObservationIgnored private var watchdog: Task<Void, Never>?

    public init() {
        delegateProxy.onConnectionChange = { [weak self] connected in
            Task { @MainActor in
                self?.setConnected(connected)
            }
        }
        manager.delegate = delegateProxy
    }

    deinit {
        watchdog?.cancel()
    }

    // MARK: - 모니터링 제어

    /// 관찰을 시작한다. 모션 권한 프롬프트도 이 시점에 뜬다.
    public func start() {
        guard !isMonitoring else { return }

        switch CMHeadphoneMotionManager.authorizationStatus() {
        case .denied, .restricted:
            state = .unauthorized
            return
        default:
            break
        }

        isMonitoring = true
        startedAt = Date()
        lastSampleAt = nil

        manager.startConnectionStatusUpdates()
        manager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            MainActor.assumeIsolated {
                self?.handle(motion: motion, error: error)
            }
        }

        startWatchdog()
    }

    /// 관찰을 멈춘다. 화면을 벗어날 때 반드시 호출해 배터리 소모를 끊는다.
    public func stop() {
        guard isMonitoring else { return }

        isMonitoring = false
        watchdog?.cancel()
        watchdog = nil
        startedAt = nil
        lastSampleAt = nil
        lastPublishedAt = nil
        latestSample = nil

        manager.stopDeviceMotionUpdates()
        manager.stopConnectionStatusUpdates()
    }

    // MARK: - 상태 갱신

    private func handle(motion: CMDeviceMotion?, error: Error?) {
        guard isMonitoring else { return }

        // 샘플이 없는 콜백은 착용 해제/일시적 끊김이므로 watchdog 이 처리한다.
        guard error == nil, let motion else { return }

        let now = Date()
        lastSampleAt = now
        isConnected = true
        state = .worn

        let sample = AirPodsMotionSample(motion: motion)
        onDeviceMotion?(sample)

        if let lastPublishedAt, now.timeIntervalSince(lastPublishedAt) < Self.publishInterval {
            return
        }
        lastPublishedAt = now
        latestSample = sample
    }

    private func setConnected(_ connected: Bool) {
        guard isMonitoring else { return }

        isConnected = connected
        if !connected {
            lastSampleAt = nil
        }
        evaluate(now: Date())
    }

    private func startWatchdog() {
        watchdog?.cancel()
        watchdog = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: Self.evaluateInterval)
                guard let self else { return }
                self.evaluate(now: Date())
            }
        }
    }

    /// 샘플 흐름과 연결 상태를 합쳐 현재 상태를 다시 계산한다.
    private func evaluate(now: Date) {
        guard isMonitoring else { return }

        if let lastSampleAt, now.timeIntervalSince(lastSampleAt) < Self.wearTimeout {
            state = .worn
            return
        }

        // 착용이 끊긴 뒤에는 마지막 값이 화면에 얼어붙지 않도록 비운다.
        latestSample = nil

        if isConnected {
            state = .notWorn
            return
        }

        // 연결 이력이 없는 경우에만 지원 여부를 따진다. 시작 직후에는 연결
        // 콜백이 아직 도착하지 않았을 수 있어 유예 시간을 둔다.
        let elapsed = startedAt.map { now.timeIntervalSince($0) } ?? 0
        if !manager.isDeviceMotionAvailable, elapsed > Self.unsupportedGrace {
            state = .unsupported
        } else {
            state = .disconnected
        }
    }
}

// MARK: - Delegate Proxy

/// `@Observable` 클래스가 `NSObject` 를 상속하지 않도록 델리게이트만 분리한다.
private final class HeadphoneMotionDelegateProxy: NSObject, CMHeadphoneMotionManagerDelegate, @unchecked Sendable {

    var onConnectionChange: (@Sendable (Bool) -> Void)?

    func headphoneMotionManagerDidConnect(_ manager: CMHeadphoneMotionManager) {
        onConnectionChange?(true)
    }

    func headphoneMotionManagerDidDisconnect(_ manager: CMHeadphoneMotionManager) {
        onConnectionChange?(false)
    }
}
