import SwiftUI
import MainFeatureInterface

public enum MainFeatureImpl {
    
    public static func makeMainView() -> some View {
        MainView()
    }
    
    public static func makeActionView(onComplete: @escaping (Int) -> Void) -> some View {
        ActionView(onComplete: onComplete)
    }
}
