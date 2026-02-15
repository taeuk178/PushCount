import SwiftUI

public protocol HomeFeatureInterface {
    associatedtype HomeView: View
    static func makeHomeView() -> HomeView
}
