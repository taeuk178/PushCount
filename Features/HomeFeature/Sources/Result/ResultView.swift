//
//  ResultView.swift
//  HomeFeature
//
//  Created by taeuk on 8/30/25.
//

import SwiftUI
import HomeFeatureInterface
import DesignSystemKit
import CharacterKit

/// 운동 결과 요약.
///
/// 지표는 실제로 측정한 값만 크게 보여준다. 칼로리처럼 추정치는 "약" 을 붙여
/// 위계를 낮춘다. 실측과 추정이 같은 크기로 나란히 있으면 기록 전체가
/// 덜 믿음직해진다.
struct ResultView: View {

    let exercise: Exercise
    let pushCount: Int
    let elapsedSeconds: Int
    let onDismiss: (Int) -> Void

    @State private var appeared = false

    var body: some View {
        ZStack {
            DesignColor.canvas
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header

                Spacer(minLength: 0)

                PushUpCharacterView(
                    phase: 1,
                    mood: .cheering,
                    palette: exercise.palette,
                    scale: 1.15
                )

                summary

                Spacer(minLength: 0)

                metrics

                Spacer(minLength: 0)

                footer
            }
            .padding(.horizontal, DesignSpacing.screen)
            .padding(.top, DesignSpacing.md)
            .padding(.bottom, DesignSpacing.lg)
        }
        .task {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.1)) {
                appeared = true
            }
        }
    }
}

// MARK: - 구성 요소

private extension ResultView {

    var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("수고했어요!")
                    .font(DesignFont.display)
                    .foregroundStyle(DesignColor.ink)

                Text("\(formattedDate) · \(exercise.name)")
                    .font(DesignFont.body)
                    .foregroundStyle(DesignColor.inkMuted)
            }

            Spacer()

            DSIconButton(systemName: "xmark", palette: DesignColor.muted) {
                onDismiss(pushCount)
            }
        }
    }

    var summary: some View {
        VStack(spacing: DesignSpacing.xs) {
            Text("\(pushCount)")
                .font(DesignFont.counter(88))
                .foregroundStyle(exercise.palette.main)
                .lineLimit(1)
                .minimumScaleFactor(0.6)

            Text("총 횟수")
                .font(DesignFont.headline)
                .foregroundStyle(DesignColor.inkMuted)
        }
        .scaleEffect(appeared ? 1 : 0.7)
        .opacity(appeared ? 1 : 0)
    }

    var metrics: some View {
        DSCard(padding: DesignSpacing.md) {
            HStack(spacing: 0) {
                DSStat(value: formattedDuration, label: "운동 시간")

                divider

                DSStat(value: formattedPerMinute, label: "분당 횟수")

                divider

                DSStat(value: "약 \(estimatedCalories)", label: "칼로리")
            }
        }
    }

    var divider: some View {
        Rectangle()
            .fill(DesignColor.line)
            .frame(width: 1, height: 32)
    }

    var footer: some View {
        VStack(spacing: DesignSpacing.sm) {
            Button {
                onDismiss(pushCount)
            } label: {
                Text("완료")
            }
            .buttonStyle(DSButtonStyle(palette: exercise.palette, height: 58))

            Button {
            } label: {
                HStack(spacing: DesignSpacing.sm) {
                    Image(systemName: "square.and.arrow.up")
                    Text("친구에게 공유하기")
                }
            }
            .buttonStyle(DSQuietButtonStyle())
        }
    }
}

// MARK: - 값 계산

private extension ResultView {

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일 EEEE"
        return formatter.string(from: Date())
    }

    /// 실제로 측정한 시간.
    var formattedDuration: String {
        String(format: "%02d:%02d", elapsedSeconds / 60, elapsedSeconds % 60)
    }

    /// 실측 횟수와 실측 시간으로 계산한 값.
    var formattedPerMinute: String {
        guard elapsedSeconds > 0 else { return "0.0" }
        let perMinute = Double(pushCount) / (Double(elapsedSeconds) / 60)
        return String(format: "%.1f", perMinute)
    }

    /// 횟수 기반 추정치. 측정한 값이 아니라서 "약" 을 붙여 보여준다.
    var estimatedCalories: Int {
        max(Int(Double(pushCount) * 0.32), 1)
    }
}

#Preview {
    ResultView(exercise: .pushUp, pushCount: 37, elapsedSeconds: 214) { _ in }
}
