//
//  MotionReadoutView.swift
//  HomeFeature
//
//  Created by taeuk on 8/1/26.
//

import SwiftUI

import DesignSystemKit
import MotionKit

/// 운동 중 에어팟 모션 데이터를 실시간으로 보여주는 패널.
struct MotionReadoutView: View {

    /// 파형에서 ±1.0G 를 가득 찬 높이로 그린다.
    private static let accelerationScale: Double = 1.0

    let state: AirPodsMotionState
    let sample: AirPodsMotionSample?
    let history: [Double]
    let phase: Double
    let isTracking: Bool
    let isPostureValid: Bool
    let autoCount: Int

    var body: some View {
        VStack(spacing: 12) {
            header

            if state.isReadyForWorkout {
                waveform
                    .frame(height: 44)

                phaseBar
                    .frame(height: 6)

                HStack(spacing: 0) {
                    metric(title: "자동 감지", value: "\(autoCount)", unit: "회")
                    divider
                    metric(title: "상하 데이터", value: formatted(sample?.verticalAcceleration), unit: "G")
                    divider
                    metric(
                        title: "고개 각도",
                        value: formatted(sample?.pitch, decimals: 0),
                        unit: "°",
                        color: isPostureValid ? DesignColor.white : DesignColor.brandOrange
                    )
                }
            } else {
                Text(state.message)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(DesignColor.white.opacity(0.5))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(DesignColor.white.opacity(0.06))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(DesignColor.white.opacity(0.12), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .animation(.easeInOut(duration: 0.25), value: state)
    }
}

private extension MotionReadoutView {

    var header: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(indicatorColor)
                .frame(width: 7, height: 7)

            Text(headerTitle)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(DesignColor.white.opacity(0.75))

            Spacer()

            if state.isReadyForWorkout {
                Text("AirPods")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(DesignColor.white.opacity(0.35))
            }
        }
    }

    var headerTitle: String {
        guard state.isReadyForWorkout else { return state.title }
        if !isPostureValid { return "엎드린 자세가 아닙니다" }
        return isTracking ? "푸시업 감지 중" : "동작 대기 중"
    }

    var indicatorColor: Color {
        guard state.isReadyForWorkout, isPostureValid else { return DesignColor.white.opacity(0.3) }
        return isTracking ? DesignColor.successGreen : DesignColor.brandOrange
    }

    /// 현재 동작 위상. 한 번 내려갔다 올라오면 막대가 좌우로 한 번 왕복한다.
    var phaseBar: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(DesignColor.white.opacity(0.10))

                Capsule()
                    .fill(isTracking ? DesignColor.brandOrange : DesignColor.white.opacity(0.25))
                    .frame(width: max(6, proxy.size.width * 0.12))
                    .offset(x: (proxy.size.width - max(6, proxy.size.width * 0.12)) * min(max(phase, 0), 1))
            }
        }
        .animation(.linear(duration: 0.08), value: phase)
        .accessibilityHidden(true)
    }

    /// 중력 축 가속도의 최근 흐름. 푸시업 한 번이 위아래 한 쌍의 진폭으로 보인다.
    var waveform: some View {
        Canvas { context, size in
            guard !history.isEmpty else { return }

            let midY = size.height / 2
            let barWidth = size.width / CGFloat(history.count)
            let inset = min(1.5, barWidth * 0.3)

            context.stroke(
                Path { $0.addLines([CGPoint(x: 0, y: midY), CGPoint(x: size.width, y: midY)]) },
                with: .color(DesignColor.white.opacity(0.12)),
                lineWidth: 1
            )

            for (index, value) in history.enumerated() {
                let normalized = max(-1, min(1, value / Self.accelerationScale))
                let height = abs(normalized) * midY
                guard height > 0.5 else { continue }

                let x = CGFloat(index) * barWidth
                let rect = CGRect(
                    x: x + inset / 2,
                    y: normalized >= 0 ? midY : midY - height,
                    width: max(1, barWidth - inset),
                    height: height
                )

                // 오래된 값일수록 흐리게 그려 진행 방향을 드러낸다.
                let freshness = Double(index + 1) / Double(history.count)
                context.fill(
                    Path(roundedRect: rect, cornerRadius: 1),
                    with: .color(DesignColor.brandOrange.opacity(0.25 + 0.75 * freshness))
                )
            }
        }
        .accessibilityHidden(true)
    }

    var divider: some View {
        Rectangle()
            .fill(DesignColor.white.opacity(0.10))
            .frame(width: 1, height: 26)
    }

    func metric(title: String, value: String, unit: String, color: Color = DesignColor.white) -> some View {
        VStack(spacing: 3) {
            Text(title)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(DesignColor.white.opacity(0.4))

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 17, weight: .heavy).monospacedDigit())
                    .foregroundStyle(color)

                Text(unit)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(DesignColor.white.opacity(0.4))
            }
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title) \(value)\(unit)")
    }

    func formatted(_ value: Double?, decimals: Int = 2) -> String {
        guard let value else { return "–" }
        return String(format: "%.\(decimals)f", value)
    }
}

#Preview {
    VStack(spacing: 16) {
        MotionReadoutView(
            state: .worn,
            sample: nil,
            history: (0..<48).map { sin(Double($0) / 4) * 0.6 },
            phase: 0.7,
            isTracking: true,
            isPostureValid: true,
            autoCount: 12
        )

        MotionReadoutView(
            state: .worn,
            sample: nil,
            history: [],
            phase: 0,
            isTracking: false,
            isPostureValid: false,
            autoCount: 0
        )

        MotionReadoutView(
            state: .notWorn,
            sample: nil,
            history: [],
            phase: 0,
            isTracking: false,
            isPostureValid: false,
            autoCount: 0
        )
    }
    .padding(24)
    .background(DesignColor.black)
}
