import SwiftUI
import HomeFeature

@main
struct HomeFeatureExampleApp: App {
    var body: some Scene {
        WindowGroup {
            HomeFeatureImpl.makeHomeView()
        }
    }
}
