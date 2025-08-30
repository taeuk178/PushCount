import SwiftUI
import SettingFeature
import MainFeature

public struct ContentView: View {
    
    public init() {}

    public var body: some View {
        TabView {
            MainFeatureImpl.makeMainView()
                .tabItem {
                    Image(systemName: "1.square.fill")
                    Text("First")
                }
            SettingFeatureImpl.makeSettingView()
                .tabItem {
                    Image(systemName: "2.square.fill")
                    Text("Setting")
                }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
