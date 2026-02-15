
import SwiftUI

public protocol RecordFeatureInterface {
    associatedtype RecordView: View
    static func makeRecordView() -> RecordView
}
