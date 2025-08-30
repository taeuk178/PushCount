import SwiftUI

public protocol SettingFeatureInterface {
    associatedtype SettingView: View
    static func makeSettingView() -> SettingView
}