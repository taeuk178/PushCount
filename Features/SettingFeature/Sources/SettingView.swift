import SwiftUI
import SettingFeatureInterface

public struct SettingView: View {
    
    @State private var hapticFeedbackEnabled = true
    
    public init() {}
    
    public var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("환경 설정")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Color(red: 1, green: 0.33, blue: 0))
                        .tracking(1.2)
                    
                    Text("설정")
                        .font(.system(size: 32, weight: .heavy))
                        .foregroundStyle(.white)
                    
                    Text("앱 환경과 운동 환경을 관리하세요")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color(red: 0.61, green: 0.64, blue: 0.69))
                }
                
                settingsSection(title: "일반") {
                    settingsToggleRow(
                        icon: "iphone.radiowaves.left.and.right",
                        title: "진동 피드백",
                        subtitle: "카운트 시 햅틱 피드백",
                        isOn: $hapticFeedbackEnabled
                    )
                    settingsInfoRow(
                        icon: "info.circle",
                        title: "앱 버전",
                        value: "1.0.0"
                    )
                }
                
                settingsSection(title: "지원") {
                    settingsLinkRow(
                        icon: "questionmark.circle",
                        title: "도움말",
                        subtitle: "앱 사용 방법과 FAQ"
                    )
                    settingsLinkRow(
                        icon: "envelope",
                        title: "문의하기",
                        subtitle: "개발팀에 피드백 보내기"
                    )
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 52)
            .padding(.bottom, 28)
        }
    }
}

private extension SettingView {
    func settingsSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)
            
            VStack(spacing: 0) {
                content()
            }
            .background(Color.white.opacity(0.05))
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color(red: 1, green: 0.33, blue: 0).opacity(0.28), lineWidth: 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
    
    func settingsToggleRow(icon: String, title: String, subtitle: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color(red: 1, green: 0.33, blue: 0))
                .frame(width: 26)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.white.opacity(0.48))
            }
            
            Spacer()
            
            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(Color(red: 1, green: 0.33, blue: 0))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .overlay(alignment: .bottom) {
            Divider().background(Color.white.opacity(0.08))
        }
    }
    
    func settingsInfoRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color(red: 1, green: 0.33, blue: 0))
                .frame(width: 26)
            
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.white.opacity(0.6))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
    }
    
    func settingsLinkRow(icon: String, title: String, subtitle: String) -> some View {
        Button {
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color(red: 1, green: 0.33, blue: 0))
                    .frame(width: 26)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                    Text(subtitle)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.white.opacity(0.48))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.white.opacity(0.45))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
        .overlay(alignment: .bottom) {
            Divider().background(Color.white.opacity(0.08))
        }
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
