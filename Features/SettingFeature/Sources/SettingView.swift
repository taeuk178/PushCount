import SwiftUI
import SettingFeatureInterface
import DesignSystemKit

public struct SettingView: View {
    
    @AppStorage("hapticFeedbackEnabled") private var hapticFeedbackEnabled = true
    @AppStorage("outdoorWorkoutRecommendationEnabled") private var outdoorWorkoutRecommendationEnabled = false
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                DesignColor.black
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        settingsSection(title: "일반") {
                            settingsToggleRow(
                                icon: "iphone.radiowaves.left.and.right",
                                title: "진동 피드백",
                                subtitle: "카운트 시 햅틱 피드백",
                                isOn: $hapticFeedbackEnabled,
                                showDivider: true
                            )
                            settingsToggleRow(
                                icon: "figure.run",
                                title: "야외 운동 추천",
                                subtitle: "홈에서 가까운 공원 안내 표시",
                                isOn: $outdoorWorkoutRecommendationEnabled,
                                showDivider: false
                            )
                        }
                        
                        settingsSection(title: "지원") {
                            settingsLinkRow(
                                icon: "questionmark.circle",
                                title: "도움말",
                                subtitle: "앱 사용 방법과 FAQ",
                                showDivider: true
                            )
                            settingsLinkRow(
                                icon: "envelope",
                                title: "문의하기",
                                subtitle: "개발팀에 피드백 보내기",
                                showDivider: false
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("설정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(DesignColor.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .tint(DesignColor.brandOrange)
    }
}

private extension SettingView {
    func settingsSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(DesignColor.sand200)
            
            VStack(spacing: 0) {
                content()
            }
            .background(DesignColor.settingCardOverlay)
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(DesignColor.white.opacity(0.12), lineWidth: 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
    
    func settingsToggleRow(
        icon: String,
        title: String,
        subtitle: String,
        isOn: Binding<Bool>,
        showDivider: Bool
    ) -> some View {
        HStack(spacing: 12) {
            iconChip(systemName: icon)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(DesignColor.white)
                Text(subtitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(DesignColor.white.opacity(0.48))
            }
            
            Spacer()
            
            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(DesignColor.brandOrange)
                .background(DesignColor.toggleTrackOff.opacity(isOn.wrappedValue ? 0 : 1))
                .clipShape(Capsule())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .overlay(alignment: .bottom) {
            if showDivider {
                Divider().background(DesignColor.white.opacity(0.12))
            }
        }
    }
    
    func settingsLinkRow(icon: String, title: String, subtitle: String, showDivider: Bool) -> some View {
        Button {
        } label: {
            HStack(spacing: 12) {
                iconChip(systemName: icon)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(DesignColor.white)
                    Text(subtitle)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(DesignColor.white.opacity(0.48))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(DesignColor.white.opacity(0.45))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
        .overlay(alignment: .bottom) {
            if showDivider {
                Divider().background(DesignColor.white.opacity(0.12))
            }
        }
    }
    
    func iconChip(systemName: String) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(DesignColor.settingIconOverlay)
            Image(systemName: systemName)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(DesignColor.brandOrange)
        }
        .frame(width: 32, height: 32)
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
