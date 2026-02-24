
import SwiftUI
import LoginFeature

@main
struct LoginFeatureExampleApp: App {
    var body: some Scene {
        WindowGroup {
            LoginFeatureImpl.makeLoginView()
        }
    }
}
