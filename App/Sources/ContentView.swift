import SwiftUI
import SettingFeature
import MainFeature

public struct ContentView: View {
    
    public init() {}

    public var body: some View {
        TabView {
            MainFeatureImpl.makeMainView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("홈")
                }
            
            RecordView()
                .tabItem {
                    Image(systemName: "clock.fill")
                    Text("기록")
                }
            
            SettingFeatureImpl.makeSettingView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("설정")
                }
        }
    }
}

private struct RecordView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                Text("기록")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("운동 기록 화면은 준비 중입니다.")
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("기록")
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
