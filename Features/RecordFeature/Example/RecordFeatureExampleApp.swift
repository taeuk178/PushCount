
import SwiftUI
import RecordFeature

@main
struct MainFeatureExampleApp: App {
    var body: some Scene {
        WindowGroup {
            RecordFeatureImpl.makeRecordView()
        }
    }
}
