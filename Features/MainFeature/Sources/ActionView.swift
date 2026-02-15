//
//  ActionView.swift
//  MainFeature
//
//  Created by taeuk on 8/30/25.
//

import SwiftUI
import MainFeatureInterface

struct ActionView: View {
    
    @State private var pushCount: Int = 0
    @State private var showResultView = false
    let exerciseTitle: String
    let onComplete: (Int) -> Void
    @Environment(\.dismiss) private var dismiss
    
    init(exerciseTitle: String = "PUSH UPS", onComplete: @escaping (Int) -> Void) {
        self.exerciseTitle = exerciseTitle
        self.onComplete = onComplete
    }
    
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
                    ResultView(pushCount: pushCount) { completedCount in
                        showResultView = false
                        onComplete(completedCount)
                        dismiss()
                    }
                }
            }
            
            Text(exerciseTitle)
                .font(.system(size: 24, weight: .bold))
            
            Text("\(pushCount)")
                .font(.system(size: 60, weight: .bold))
            
//            HStack(spacing: 50) {
//                Text("오늘의 목표")
//                
//                Text("50")
//            }
            
            VStack(spacing: 80) {
                HStack(spacing: 40) {
                    Button {
                        if pushCount == 0 { return }
                        pushCount -= 1
                    } label: {
                        Text("-1")
                            .font(.system(size: 24, weight: .bold))
                            .frame(width: 60, height: 50)
                            .foregroundStyle(Color.white)
                            .background(Color.black)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    Button {
                        pushCount += 1
                    } label: {
                        Text("+1")
                            .font(.system(size: 24, weight: .bold))
                            .frame(width: 60, height: 50)
                            .foregroundStyle(Color.white)
                            .background(Color.black)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
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
}

#Preview {
    ActionView { count in
        print("Completed push count: \(count)")
    }
}
