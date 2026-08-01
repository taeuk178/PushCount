
import SwiftUI

import HomeFeature
import RecordFeature
import SettingFeature
import LoginFeature
import DesignSystemKit

public struct ContentView: View {

    public init() {}

    public var body: some View {
        TabView {
            HomeFeatureImpl.makeHomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("홈")
                }

            RecordFeatureImpl.makeRecordView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("기록")
                }

            SettingFeatureImpl.makeSettingView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("설정")
                }
        }
        .tint(DesignColor.brand.main)
    }
}

#Preview {
    ContentView()
}
