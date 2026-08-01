import SwiftUI
import HomeFeatureInterface
import MotionKit

public enum HomeFeatureImpl {

    public static func makeHomeView() -> some View {
        HomeView()
    }

    @MainActor
    public static func makeActionView(
        motionMonitor: AirPodsMotionMonitor,
        onComplete: @escaping (Int) -> Void
    ) -> some View {
        ActionView(motionMonitor: motionMonitor, onComplete: onComplete)
    }
}
