import SwiftUI
import MainFeatureInterface

public enum MainFeatureImpl {
    
    public static func makeMainView() -> some View {
        MainView()
    }
    
    public static func makeActionView() -> some View {
        ActionView()
    }
}
