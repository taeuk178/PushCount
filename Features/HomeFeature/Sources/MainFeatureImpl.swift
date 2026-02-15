import SwiftUI
import HomeFeatureInterface

public enum HomeFeatureImpl {
    
    public static func makeHomeView() -> some View {
        HomeView()
    }
    
    public static func makeActionView(onComplete: @escaping (Int) -> Void) -> some View {
        ActionView(onComplete: onComplete)
    }
}
