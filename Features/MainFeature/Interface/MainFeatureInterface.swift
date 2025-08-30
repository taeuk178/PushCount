import SwiftUI

public protocol MainFeatureInterface {
    associatedtype MainView: View
    static func makeSettingView() -> MainView
}
