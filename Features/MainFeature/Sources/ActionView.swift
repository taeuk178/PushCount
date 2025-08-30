//
//  ActionView.swift
//  MainFeature
//
//  Created by taeuk on 8/30/25.
//

import SwiftUI
import MainFeatureInterface

struct ActionView: View {
    
    @State private var showResultView = false
    
    var body: some View {
        
        VStack(spacing: 20) {
            HStack(alignment: .top, spacing: 0) {
                
                Spacer()
                
                Button {
                    showResultView = true
                } label: {
                    Text("종료")
                        .frame(width: 60, height: 30)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.red)
                        .background(Color.yellow)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .fullScreenCover(isPresented: $showResultView) {
                    ResultView()
                }
            }
            
            Text("23")
                .font(.system(size: 60, weight: .bold))
            
            HStack(spacing: 50) {
                Text("오늘의 목표")
                
                Text("50")
            }
            
            Button {
                
            } label: {
                Text("일시 정지")
                    .frame(width: 200, height: 40)
                    .foregroundStyle(Color.white)
                    .background(Color.black)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
            }

        }

        
    }
}

#Preview {
    ActionView()
}
