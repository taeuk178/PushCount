
import SwiftUI

import HomeFeature
import RecordFeature
import SettingFeature
import LoginFeature

public struct ContentView: View {
    
    public init() {}
    
    public var body: some View {
        LoginView()
    }

//    public var body: some View {
//        TabView {
//            HomeFeatureImpl.makeHomeView()
//                .tabItem {
//                    Image(systemName: "house.fill")
//                    Text("홈")
//                }
//            
//            RecordFeatureImpl.makeRecordView()
//                .tabItem {
//                    Image(systemName: "clock.fill")
//                    Text("기록")
//                }
//            
//            SettingFeatureImpl.makeSettingView()
//                .tabItem {
//                    Image(systemName: "gearshape.fill")
//                    Text("설정")
//                }
//        }
//    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
