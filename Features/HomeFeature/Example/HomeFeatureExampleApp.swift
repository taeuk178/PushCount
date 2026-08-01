import SwiftUI
import HomeFeature
import MotionKit

/// HomeFeature 단독 실행 하네스.
///
/// 운동 중 화면은 실제 흐름으로 들어가려면 에어팟이 필요해서, 화면을 직접
/// 골라 띄울 수 있게 해 둔다.
@main
struct HomeFeatureExampleApp: App {

    var body: some Scene {
        WindowGroup {
            ExampleRouter()
        }
    }
}

private struct ExampleRouter: View {

    private enum Screen: String, CaseIterable, Identifiable {
        case home = "홈"
        case action = "운동 중"

        var id: String { rawValue }

        init(rawValueKey: String?) {
            switch rawValueKey {
            case "action": self = .action
            default: self = .home
            }
        }
    }

    /// 시작 화면은 실행 인자로도 고를 수 있다. 시뮬레이터에서 특정 화면만
    /// 바로 띄울 때 쓴다. `xcrun simctl launch <device> <bundleID> -screen action`
    @State private var screen: Screen = Screen(rawValueKey: UserDefaults.standard.string(forKey: "screen"))
    @State private var motionMonitor = AirPodsMotionMonitor()

    var body: some View {
        VStack(spacing: 0) {
            Picker("화면", selection: $screen) {
                ForEach(Screen.allCases) { screen in
                    Text(screen.rawValue).tag(screen)
                }
            }
            .pickerStyle(.segmented)
            .padding(12)

            switch screen {
            case .home:
                HomeFeatureImpl.makeHomeView()
            case .action:
                HomeFeatureImpl.makeActionView(motionMonitor: motionMonitor) { _ in }
            }
        }
    }
}
