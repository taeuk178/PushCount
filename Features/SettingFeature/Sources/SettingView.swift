import SwiftUI
import SettingFeatureInterface
import DesignSystemKit

public struct SettingView: View {

    @AppStorage("hapticFeedbackEnabled") private var hapticFeedbackEnabled = true
    @AppStorage("outdoorWorkoutRecommendationEnabled") private var outdoorWorkoutRecommendationEnabled = false

    public init() {}

    public var body: some View {
        ZStack {
            DesignColor.canvas
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: DesignSpacing.lg) {
                    Text("설정")
                        .font(DesignFont.display)
                        .foregroundStyle(DesignColor.ink)

                    section(title: "일반") {
                        toggleRow(
                            icon: "iphone.radiowaves.left.and.right",
                            palette: DesignColor.push,
                            title: "진동 피드백",
                            subtitle: "카운트할 때 햅틱으로 알려줘요",
                            isOn: $hapticFeedbackEnabled,
                            showDivider: true
                        )
                        toggleRow(
                            icon: "tree.fill",
                            palette: DesignColor.success,
                            title: "야외 운동 추천",
                            subtitle: "홈에서 가까운 공원을 알려줘요",
                            isOn: $outdoorWorkoutRecommendationEnabled,
                            showDivider: false
                        )
                    }

                    section(title: "지원") {
                        linkRow(
                            icon: "questionmark.circle.fill",
                            palette: DesignColor.pull,
                            title: "도움말",
                            subtitle: "앱 사용 방법과 자주 묻는 질문",
                            showDivider: true
                        )
                        linkRow(
                            icon: "envelope.fill",
                            palette: DesignColor.sunny,
                            title: "문의하기",
                            subtitle: "개발팀에 피드백 보내기",
                            showDivider: false
                        )
                    }
                }
                .padding(.horizontal, DesignSpacing.screen)
                .padding(.top, DesignSpacing.md)
                .padding(.bottom, DesignSpacing.xl)
            }
        }
    }
}

private extension SettingView {

    func section<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: DesignSpacing.sm) {
            Text(title)
                .font(DesignFont.title)
                .foregroundStyle(DesignColor.ink)

            DSCard(padding: 0) {
                VStack(spacing: 0) {
                    content()
                }
            }
        }
    }

    func toggleRow(
        icon: String,
        palette: DesignPalette,
        title: String,
        subtitle: String,
        isOn: Binding<Bool>,
        showDivider: Bool
    ) -> some View {
        row(icon: icon, palette: palette, title: title, subtitle: subtitle, showDivider: showDivider) {
            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(palette.main)
        }
    }

    func linkRow(
        icon: String,
        palette: DesignPalette,
        title: String,
        subtitle: String,
        showDivider: Bool
    ) -> some View {
        Button {
        } label: {
            row(icon: icon, palette: palette, title: title, subtitle: subtitle, showDivider: showDivider) {
                Image(systemName: "chevron.right")
                    .font(DesignFont.label)
                    .foregroundStyle(DesignColor.inkMuted)
            }
        }
        .buttonStyle(.plain)
    }

    func row<Trailing: View>(
        icon: String,
        palette: DesignPalette,
        title: String,
        subtitle: String,
        showDivider: Bool,
        @ViewBuilder trailing: () -> Trailing
    ) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: DesignSpacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(palette.deep)
                    .frame(width: 38, height: 38)
                    .background(palette.soft, in: RoundedRectangle(cornerRadius: DesignRadius.sm, style: .continuous))

                VStack(alignment: .leading, spacing: 1) {
                    Text(title)
                        .font(DesignFont.headline)
                        .foregroundStyle(DesignColor.ink)

                    Text(subtitle)
                        .font(DesignFont.label)
                        .foregroundStyle(DesignColor.inkMuted)
                }

                Spacer(minLength: 0)

                trailing()
            }
            .padding(DesignSpacing.md)

            if showDivider {
                Rectangle()
                    .fill(DesignColor.line)
                    .frame(height: 1)
                    .padding(.leading, 62)
            }
        }
    }
}

#Preview {
    SettingView()
}
