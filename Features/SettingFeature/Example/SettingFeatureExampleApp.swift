import SwiftUI
import SettingFeature

@main
struct SettingFeatureExampleApp: App {
    var body: some Scene {
        WindowGroup {
            SettingFeatureImpl.makeSettingView()
        }
    }
}