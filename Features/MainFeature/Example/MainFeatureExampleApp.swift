import SwiftUI
import MainFeature

@main
struct MainFeatureExampleApp: App {
    var body: some Scene {
        WindowGroup {
            MainFeatureImpl.makeSettingView()
        }
    }
}
