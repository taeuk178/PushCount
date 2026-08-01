//
//  ActionView.swift
//  HomeFeature
//
//  Created by taeuk on 8/30/25.
//

import SwiftUI
import HomeFeatureInterface
import DesignSystemKit
import MotionKit

struct ActionView: View {

    /// 파형에 남겨둘 샘플 수. 12Hz 기준 약 4초 분량.
    private static let historyCapacity = 48

    @State private var manualCount: Int = 0
    @State private var elapsedSeconds: Int = 0
    @State private var isPaused = false
    @State private var isLocked = false
    @State private var showResultView = false
    @State private var accelerationHistory: [Double] = []
    @State private var counter = PushUpCounter()

    /// 카운트 햅틱. 매번 새로 만들면 첫 사용 때 Taptic Engine 초기화로
    /// 메인 스레드가 잠깐 멈추므로, 하나를 유지하고 미리 예열해 둔다.
    @State private var hapticGenerator = UIImpactFeedbackGenerator(style: .medium)

    /// 에어팟이 감지한 횟수 + 탭으로 보정한 횟수.
    private var pushCount: Int { counter.repCount + manualCount }

    private let targetCount = 50
    let exerciseTitle: String
    let motionMonitor: AirPodsMotionMonitor
    let onComplete: (Int) -> Void

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @Environment(\.dismiss) private var dismiss

    init(
        exerciseTitle: String = "PUSH UPS",
        motionMonitor: AirPodsMotionMonitor,
        onComplete: @escaping (Int) -> Void
    ) {
        self.exerciseTitle = exerciseTitle
        self.motionMonitor = motionMonitor
        self.onComplete = onComplete
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [DesignColor.black, DesignColor.deepOrangeBackground, DesignColor.black],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            Circle()
                .fill(DesignColor.brandOrange.opacity(0.20))
                .frame(width: 520, height: 520)
                .blur(radius: 60)
                .offset(y: 100)
            
            VStack(spacing: 0) {
                headerView
                    .padding(.top, 20)
                    .padding(.horizontal, 24)
                
                mainCounterArea
                    .contentShape(Rectangle())
                    .onTapGesture {
                        guard !isPaused, !isLocked else { return }
                        manualCount += 1
                    }
                
                footerView
                    .padding(.horizontal, 24)
                    .padding(.bottom, 26)
                    .padding(.top, 14)
            }
        }
        .onReceive(timer) { _ in
            guard !isPaused else { return }
            elapsedSeconds += 1
        }
        .task {
            // HomeView 가 이미 시작한 경우 내부에서 무시된다. 운동 화면만
            // 단독으로 띄우는 경로에서도 모션이 흐르도록 보장하는 용도.
            print("[PUSHUP] 운동 시작 — \(exerciseTitle), 에어팟 상태: \(motionMonitor.state.title)")
            motionMonitor.start()
            counter.reset()
            counter.attach(to: motionMonitor)
            hapticGenerator.prepare()
        }
        .onDisappear {
            counter.detach()
            print("[PUSHUP] 운동 화면 종료 — 자동 \(counter.repCount)회 + 수동 \(manualCount)회 = \(pushCount)회")
        }
        .onChange(of: isPaused) { _, paused in
            counter.isPaused = paused
        }
        .onChange(of: counter.repCount) { _, _ in
            hapticGenerator.impactOccurred()
            // 다음 카운트를 위해 엔진을 계속 예열 상태로 유지한다.
            hapticGenerator.prepare()
        }
        .onChange(of: motionMonitor.latestSample) { _, sample in
            guard !isPaused, let sample else { return }
            appendToHistory(sample.verticalAcceleration)
        }
        .fullScreenCover(isPresented: $showResultView) {
            ResultView(pushCount: pushCount) { completedCount in
                showResultView = false
                onComplete(completedCount)
                dismiss()
            }
        }
    }
}

private extension ActionView {
    var headerView: some View {
        HStack {
            circleIconButton(systemName: "xmark") {
                showResultView = true
            }
            
            Spacer()
            
            VStack(spacing: 4) {
                Text(exerciseTitle)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(DesignColor.brandOrange)
                
                Text("목표: \(targetCount) 회")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(DesignColor.white.opacity(0.65))
            }
            
            Spacer()
            
            circleIconButton(systemName: "gearshape.fill") {
            }
            .opacity(0.9)
        }
    }
    
    var mainCounterArea: some View {
        VStack(spacing: 26) {
            Text(counter.isTracking ? "자동으로 세는 중 · 탭하면 보정" : "탭해서 횟수 올리기")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(DesignColor.white.opacity(0.85))
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(DesignColor.white.opacity(0.08))
                .clipShape(Capsule())
                .padding(.top, 36)
            
            ZStack {
                Circle()
                    .stroke(DesignColor.brandOrange.opacity(0.22), lineWidth: 1)
                    .frame(width: 250, height: 250)
                
                Circle()
                    .stroke(DesignColor.brandOrange.opacity(0.10), lineWidth: 1)
                    .frame(width: 320, height: 320)
                
                VStack(spacing: 6) {
                    Text("\(pushCount)")
                        .font(.system(size: 132, weight: .heavy))
                        .foregroundStyle(DesignColor.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                    
                    Text("회 완료")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(DesignColor.brandOrange)
                }
            }
            .padding(.top, 16)
            .padding(.bottom, 26)
            
            HStack(spacing: 48) {
                statBlock(title: "시간", value: formattedTime)
                statBlock(title: "평균 페이스", value: "\(formattedPace) 초")
            }
            .padding(.top, 8)

            MotionReadoutView(
                state: motionMonitor.state,
                sample: motionMonitor.latestSample,
                history: accelerationHistory,
                phase: counter.phase,
                isTracking: counter.isTracking,
                isPostureValid: counter.isPostureValid,
                autoCount: counter.repCount
            )
            .padding(.horizontal, 24)
            .padding(.top, 18)

            Spacer(minLength: 0)
        }
    }
    
    var footerView: some View {
        VStack(spacing: 24) {
            HStack(spacing: 28) {
                smallActionButton(systemName: "stop.fill", title: "완료") {
                    showResultView = true
                }
                
                Button {
                    isPaused.toggle()
                } label: {
                    ZStack {
                        Circle()
                            .fill(DesignColor.brandOrange)
                            .frame(width: 94, height: 94)
                            .shadow(color: DesignColor.brandOrange.opacity(0.4), radius: 16)
                        
                        Image(systemName: isPaused ? "play.fill" : "pause.fill")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundStyle(DesignColor.white)
                    }
                }
                .buttonStyle(.plain)
                
                smallActionButton(systemName: isLocked ? "lock.fill" : "lock.open.fill", title: "잠금") {
                    isLocked.toggle()
                }
            }
        }
    }
    
    func statBlock(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(DesignColor.white.opacity(0.45))
            
            Text(value)
                .font(.system(size: 40, weight: .heavy))
                .foregroundStyle(DesignColor.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }
    
    func circleIconButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Circle()
                .fill(DesignColor.white.opacity(0.10))
                .frame(width: 40, height: 40)
                .overlay {
                    Image(systemName: systemName)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(DesignColor.white.opacity(0.88))
                }
        }
        .buttonStyle(.plain)
    }
    
    func smallActionButton(systemName: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Circle()
                    .fill(DesignColor.white.opacity(0.08))
                    .frame(width: 48, height: 48)
                    .overlay {
                        Circle()
                            .stroke(DesignColor.white.opacity(0.18), lineWidth: 2)
                    }
                    .overlay {
                        Image(systemName: systemName)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(DesignColor.white.opacity(0.88))
                    }
                
                Text(title)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(DesignColor.white.opacity(0.55))
            }
        }
        .buttonStyle(.plain)
    }
    
    func appendToHistory(_ value: Double) {
        accelerationHistory.append(value)
        if accelerationHistory.count > ActionView.historyCapacity {
            accelerationHistory.removeFirst(accelerationHistory.count - ActionView.historyCapacity)
        }
    }

    var formattedTime: String {
        let minutes = elapsedSeconds / 60
        let seconds = elapsedSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var formattedPace: String {
        guard pushCount > 0 else { return "0.0" }
        let pace = Double(elapsedSeconds) / Double(pushCount)
        return String(format: "%.1f", pace)
    }
}

#Preview {
    ActionView(motionMonitor: AirPodsMotionMonitor()) { count in
        print("Completed push count: \(count)")
    }
}
