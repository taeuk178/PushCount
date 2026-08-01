//
//  ActionView.swift
//  HomeFeature
//
//  Created by taeuk on 8/30/25.
//

import SwiftUI
import HomeFeatureInterface
import DesignSystemKit
import CharacterKit
import MotionKit

/// 운동 중 화면.
///
/// 사용자는 바닥에 엎드려 있어 숫자를 읽을 수 없다. 그래서 이 화면은
/// 캐릭터 · 햅틱만 남기고 나머지를 덜어냈다. 캐릭터가 내 동작을 그대로
/// 따라 움직이는 것이 "지금 세어지고 있다"는 가장 확실한 신호다.
struct ActionView: View {

    @State private var manualCount: Int = 0
    @State private var elapsedSeconds: Int = 0
    @State private var isPaused = false
    @State private var isLocked = false
    @State private var showResultView = false
    @State private var counter = PushUpCounter()

    /// 카운트 햅틱. 매번 새로 만들면 첫 사용 때 Taptic Engine 초기화로
    /// 메인 스레드가 잠깐 멈추므로, 하나를 유지하고 미리 예열해 둔다.
    @State private var hapticGenerator = UIImpactFeedbackGenerator(style: .medium)

    /// 에어팟이 감지한 횟수 + 탭으로 보정한 횟수.
    private var pushCount: Int { counter.repCount + manualCount }

    private var didReachGoal: Bool { pushCount >= exercise.targetCount }

    let exercise: Exercise
    let motionMonitor: AirPodsMotionMonitor
    let onComplete: (Int) -> Void

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @Environment(\.dismiss) private var dismiss

    init(
        exercise: Exercise = .pushUp,
        motionMonitor: AirPodsMotionMonitor,
        onComplete: @escaping (Int) -> Void
    ) {
        self.exercise = exercise
        self.motionMonitor = motionMonitor
        self.onComplete = onComplete
    }

    var body: some View {
        ZStack {
            exercise.palette.soft
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header
                    .padding(.horizontal, DesignSpacing.screen)
                    .padding(.top, DesignSpacing.sm)

                stage

                footer
                    .padding(.horizontal, DesignSpacing.screen)
                    .padding(.bottom, DesignSpacing.lg)
            }
        }
        .onReceive(timer) { _ in
            guard !isPaused else { return }
            elapsedSeconds += 1
        }
        .task {
            // HomeView 가 이미 시작한 경우 내부에서 무시된다. 운동 화면만
            // 단독으로 띄우는 경로에서도 모션이 흐르도록 보장하는 용도.
            motionMonitor.start()
            counter.reset()
            counter.attach(to: motionMonitor)
            hapticGenerator.prepare()
        }
        .onDisappear {
            counter.detach()
        }
        .onChange(of: isPaused) { _, paused in
            counter.isPaused = paused
        }
        .onChange(of: counter.repCount) { _, _ in
            playCountFeedback()
        }
        .fullScreenCover(isPresented: $showResultView) {
            ResultView(
                exercise: exercise,
                pushCount: pushCount,
                elapsedSeconds: elapsedSeconds
            ) { completedCount in
                showResultView = false
                onComplete(completedCount)
                dismiss()
            }
        }
    }

    private func playCountFeedback() {
        hapticGenerator.impactOccurred()
        // 다음 카운트를 위해 엔진을 계속 예열 상태로 유지한다.
        hapticGenerator.prepare()
    }
}

// MARK: - 구성 요소

private extension ActionView {

    /// 캐릭터의 표정. 자세가 어긋나면 표정으로만 알린다.
    var mood: CharacterMood {
        if didReachGoal { return .cheering }
        if isPaused { return .resting }
        if !counter.isTracking { return .resting }
        return counter.isPostureValid ? .working : .confused
    }

    var header: some View {
        VStack(spacing: DesignSpacing.sm) {
            HStack {
                DSIconButton(systemName: "xmark", palette: exercise.palette) {
                    showResultView = true
                }

                Spacer()

                Text(exercise.name)
                    .font(DesignFont.headline)
                    .foregroundStyle(exercise.palette.deep)

                Spacer()

                DSIconButton(
                    systemName: isLocked ? "lock.fill" : "lock.open.fill",
                    palette: isLocked ? DesignColor.sunny : exercise.palette
                ) {
                    isLocked.toggle()
                }
            }

            HStack(spacing: DesignSpacing.sm) {
                DSProgressBar(
                    progress: Double(pushCount) / Double(exercise.targetCount),
                    palette: exercise.palette
                )

                Text("\(pushCount)/\(exercise.targetCount)")
                    .font(DesignFont.numeric(14))
                    .foregroundStyle(exercise.palette.deep)
            }
        }
    }

    /// 캐릭터와 숫자. 이 영역 어디를 눌러도 한 번 보정된다.
    var stage: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)

            PushUpCharacterView(
                phase: counter.phase,
                mood: mood,
                palette: exercise.palette,
                scale: 1.35
            )

            HStack(alignment: .lastTextBaseline, spacing: DesignSpacing.xs) {
                Text("\(pushCount)")
                    .font(DesignFont.counter(96))
                    .foregroundStyle(DesignColor.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .contentTransition(.numericText())

                Text("회")
                    .font(DesignFont.title)
                    .foregroundStyle(DesignColor.inkMuted)
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: pushCount)

            Text(hintText)
                .font(DesignFont.label)
                .foregroundStyle(DesignColor.inkMuted)
                .padding(.top, DesignSpacing.xs)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            guard !isPaused, !isLocked else { return }
            manualCount += 1
            playCountFeedback()
        }
    }

    var hintText: String {
        if isLocked { return "화면이 잠겨 있어요" }
        if isPaused { return "잠시 쉬는 중" }
        if counter.isTracking { return "자동으로 세는 중 · 탭하면 보정" }
        return "화면을 탭해서 세기"
    }

    var footer: some View {
        VStack(spacing: DesignSpacing.md) {
            HStack(spacing: 0) {
                DSStat(value: formattedTime, label: "시간", size: 22)
                DSStat(value: "\(formattedPace)초", label: "평균 페이스", size: 22)
            }

            Button {
                isPaused.toggle()
            } label: {
                HStack(spacing: DesignSpacing.sm) {
                    Image(systemName: isPaused ? "play.fill" : "pause.fill")
                    Text(isPaused ? "이어서 하기" : "일시정지")
                }
            }
            .buttonStyle(
                DSButtonStyle(
                    palette: isPaused ? DesignColor.success : exercise.palette,
                    height: 56
                )
            )
        }
    }

    var formattedTime: String {
        String(format: "%02d:%02d", elapsedSeconds / 60, elapsedSeconds % 60)
    }

    var formattedPace: String {
        guard pushCount > 0 else { return "0.0" }
        return String(format: "%.1f", Double(elapsedSeconds) / Double(pushCount))
    }
}

#Preview {
    ActionView(motionMonitor: AirPodsMotionMonitor()) { _ in }
}
