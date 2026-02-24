
import SwiftUI
import RecordFeature

@main
struct RecordFeatureExampleApp: App {
    var body: some Scene {
        WindowGroup {
            RecordFeatureImpl.makeRecordView()
        }
    }
}
