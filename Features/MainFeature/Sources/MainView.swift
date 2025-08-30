import SwiftUI
import MainFeatureInterface

public struct MainView: View {
    
    public init() {}
    
    @State private var showingActionView = false
    
    public var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 10) {
                Text("오늘의 푸시업")
                
                Text("38")
                    .font(.system(size: 48))
            }
            
//            Spacer()
            
            Button {
                showingActionView = true
            } label: {
                Text("운동 시작하기")
                    .frame(width: 200, height: 50)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.white)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
            }
            .fullScreenCover(isPresented: $showingActionView) {
                ActionView()
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
