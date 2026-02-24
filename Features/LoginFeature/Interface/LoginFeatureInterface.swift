
import SwiftUI

public protocol LoginFeatureInterface {
    associatedtype LoginView: View
    static func makeLoginView() -> LoginView
}
