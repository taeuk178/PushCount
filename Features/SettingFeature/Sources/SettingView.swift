import SwiftUI
import SettingFeatureInterface

public struct SettingView: View {
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            List {
                Section("General") {
                    HStack {
                        Image(systemName: "person.circle")
                        Text("앱 버전")
                        Spacer()
                        Text("1.0.0")
                    }
                }
                
                Section("Support") {
                    HStack {
                        Image(systemName: "questionmark.circle")
                        Text("Help")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "envelope")
                        Text("Contact")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("설정")
        }
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
