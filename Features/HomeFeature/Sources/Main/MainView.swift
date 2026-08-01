import SwiftUI

import HomeFeatureInterface
import DesignSystemKit
import CharacterKit
import MotionKit

public struct HomeView: View {

    public init() {}

    @State private var showingActionView = false
    @State private var todayCount = 0
    @State private var selectedExerciseID = Exercise.pushUp.id
    @State private var airPodsMonitor = AirPodsMotionMonitor()
    @State private var showingAirPodsAlert = false
    @AppStorage("outdoorWorkoutRecommendationEnabled") private var outdoorWorkoutRecommendationEnabled = false

    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.openURL) private var openURL

    private var selectedExercise: Exercise {
        Exercise.all.first { $0.id == selectedExerciseID } ?? .pushUp
    }

    public var body: some View {
        ZStack {
            DesignColor.canvas
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: DesignSpacing.lg) {
                    greeting

                    characterStage

                    exercisePicker

                    VStack(spacing: DesignSpacing.sm) {
                        AirPodsStatusBanner(state: airPodsMonitor.state) {
                            openAppSettings()
                        }

                        if outdoorWorkoutRecommendationEnabled {
                            nearParkBanner
                        }
                    }

                    startButton
                }
                .padding(.horizontal, DesignSpacing.screen)
                .padding(.top, DesignSpacing.sm)
                .padding(.bottom, DesignSpacing.xl)
            }
        }
        .fullScreenCover(isPresented: $showingActionView) {
            ActionView(
                exercise: selectedExercise,
                motionMonitor: airPodsMonitor
            ) { completedCount in
                todayCount += completedCount
            }
        }
        .task {
            airPodsMonitor.start()
        }
        .onDisappear {
            airPodsMonitor.stop()
        }
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .active: airPodsMonitor.start()
            case .background: airPodsMonitor.stop()
            default: break
            }
        }
        .alert("에어팟 착용이 확인되지 않았어요", isPresented: $showingAirPodsAlert) {
            Button("탭으로 세기") {
                showingActionView = true
            }
            Button("취소", role: .cancel) {}
        } message: {
            Text(airPodsMonitor.state.message)
        }
    }

    /// 에어팟 착용이 확인되면 바로 시작하고, 아니면 탭 카운트로 진행할지 물어본다.
    private func startWorkout() {
        if airPodsMonitor.state.isReadyForWorkout {
            showingActionView = true
        } else {
            showingAirPodsAlert = true
        }
    }

    private func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        openURL(url)
    }
}

// MARK: - 구성 요소

private extension HomeView {

    var greeting: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: DesignSpacing.xs) {
                Text("오늘도 가볍게")
                    .font(DesignFont.display)
                    .foregroundStyle(DesignColor.ink)

                Text(todayCount > 0 ? "지금까지 \(todayCount)회 했어요" : "딱 한 세트만 해볼까요?")
                    .font(DesignFont.body)
                    .foregroundStyle(DesignColor.inkMuted)
            }

            Spacer(minLength: 0)

            if todayCount > 0 {
                DSPill("오늘 \(todayCount)회", systemImage: "flame.fill", palette: DesignColor.sunny)
                    .padding(.top, DesignSpacing.xs)
            }
        }
    }

    /// 캐릭터가 앉아 있는 무대. 화면에서 가장 큰 자리를 차지한다.
    var characterStage: some View {
        ZStack {
            RoundedRectangle(cornerRadius: DesignRadius.xl, style: .continuous)
                .fill(selectedExercise.palette.soft)

            VStack(spacing: 0) {
                Spacer(minLength: 0)

                PushUpCharacterView(
                    phase: 0.7,
                    mood: .resting,
                    palette: selectedExercise.palette,
                    scale: 1.05
                )

                Text(selectedExercise.cheer)
                    .font(DesignFont.headline)
                    .foregroundStyle(selectedExercise.palette.deep)
                    .padding(.bottom, DesignSpacing.md)
            }
        }
        .frame(height: 250)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: selectedExerciseID)
    }

    var exercisePicker: some View {
        HStack(spacing: DesignSpacing.sm) {
            ForEach(Exercise.all) { exercise in
                exerciseChip(exercise)
            }
        }
    }

    func exerciseChip(_ exercise: Exercise) -> some View {
        let isSelected = exercise.id == selectedExerciseID
        let palette = exercise.isAvailable ? exercise.palette : DesignColor.muted

        return Button {
            guard exercise.isAvailable else { return }
            selectedExerciseID = exercise.id
        } label: {
            VStack(spacing: DesignSpacing.xs) {
                Image(systemName: exercise.isAvailable ? exercise.icon : "lock.fill")
                    .font(.system(size: 18, weight: .bold, design: .rounded))

                Text(exercise.name)
                    .font(DesignFont.label)

                Text(exercise.isAvailable ? exercise.detail : "준비 중")
                    .font(DesignFont.caption)
                    .opacity(0.7)
            }
            .foregroundStyle(isSelected ? DesignColor.white : palette.deep)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSpacing.md)
            .background {
                RoundedRectangle(cornerRadius: DesignRadius.md, style: .continuous)
                    .fill(isSelected ? palette.main : palette.soft)
            }
        }
        .buttonStyle(.plain)
        .opacity(exercise.isAvailable ? 1 : 0.55)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isSelected)
    }

    var startButton: some View {
        Button {
            startWorkout()
        } label: {
            HStack(spacing: DesignSpacing.sm) {
                Image(systemName: "play.fill")
                Text("시작하기")
            }
        }
        .buttonStyle(DSButtonStyle(palette: selectedExercise.palette, height: 60))
        .padding(.top, DesignSpacing.xs)
    }

    var nearParkBanner: some View {
        HStack(spacing: DesignSpacing.sm) {
            Image(systemName: "tree.fill")
                .font(DesignFont.label)
                .foregroundStyle(DesignColor.success.deep)
                .frame(width: 32, height: 32)
                .background(DesignColor.success.soft, in: Circle())

            Text("가까운 공원이 250m 거리에 있어요")
                .font(DesignFont.body)
                .foregroundStyle(DesignColor.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(DesignFont.caption)
                .foregroundStyle(DesignColor.inkMuted)
        }
        .padding(DesignSpacing.sm)
        .background(DesignColor.surface, in: RoundedRectangle(cornerRadius: DesignRadius.md, style: .continuous))
        .shadow(color: DesignColor.ink.opacity(0.05), radius: 8, y: 2)
    }
}

#Preview {
    HomeView()
}
