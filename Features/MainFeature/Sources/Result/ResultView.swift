//
//  ResultView.swift
//  MainFeature
//
//  Created by taeuk on 8/30/25.
//

import SwiftUI
import MainFeatureInterface

struct ResultView: View {
    
    let pushCount: Int
    @Environment(\.dismiss) private var dismiss
    let onDismiss: (Int) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 10) {
                Text("운동 완료!")
                    .font(.system(size: 28, weight: .bold))

                Text(formatDateInKorean(Date()))
            }
            
            HStack(spacing: 10) {
                VStack(spacing: 5) {
                    Text("\(pushCount)")
                        .font(.system(size: 50, weight: .bold))
                    Text("총 푸시업")
                        .font(.system(size: 26, weight: .medium))
                }
            }
            
            HStack(spacing: 10) {
                VStack(spacing: 5) {
                    Text("\(calculateCalories(pushCount: pushCount))")
                        .font(.system(size: 32, weight: .bold))
                    Text("칼로리 소모")
                }
            }
            
            Button {
                onDismiss(pushCount)
            } label: {
                Text("홈으로 돌아가기")
                    .frame(width: 200, height: 50)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.blue, lineWidth: 1)
                    )
            }
        }
    }
}

extension ResultView {
    
    private func formatDateInKorean(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월 d일 a h:mm"
        return formatter.string(from: date)
    }
    
    private func calculateCalories(pushCount: Int) -> Int {
        // 푸시업 1개당 약 0.32 칼로리 소모
        let caloriesPerPushUp = 0.32
        return Int(Double(pushCount) * caloriesPerPushUp)
    }
}

//struct ResultView: View {
//    
//    var body: some View {
//        
//        VStack(spacing: 20) {
//            VStack(spacing: 10) {
//    //            Image("1.square.fill")
//                Text("운동 완료!")
//                    .font(.system(size: 28, weight: .bold))
//
//                Text("2025년 8월 29일 오후 10:25")
//            }
//            
//            HStack(spacing: 10) {
//                VStack(spacing: 5) {
//                    Text("37")
//                        .font(.system(size: 32, weight: .bold))
//                    Text("총 푸시업")
//                }
////                .background(Color.red)
////                .clipShape(RoundedRectangle(cornerRadius: 12))
//                
//                VStack(spacing: 5) {
//                    Text("4:32")
//                        .font(.system(size: 32, weight: .bold))
//                    Text("운동 시간")
//                }
////                .background(Color.red)
////                .clipShape(RoundedRectangle(cornerRadius: 12))
//            }
//            
//            HStack(spacing: 10) {
//                VStack(spacing: 5) {
//                    Text("127")
//                        .font(.system(size: 32, weight: .bold))
//                    Text("칼로리 소모")
//                }
////                .background(Color.red)
////                .clipShape(RoundedRectangle(cornerRadius: 12))
//                
//                VStack(spacing: 5) {
//                    Text("22")
//                        .font(.system(size: 32, weight: .bold))
//                    Text("분당 개수")
//                }
////                .background(Color.red)
////                .clipShape(RoundedRectangle(cornerRadius: 12))
//            }
//            
//            VStack(alignment: .leading, spacing: 20) {
//                Text("AI 코치 조언")
//                
//                VStack(alignment: .leading, spacing: 10) {
//                    VStack(alignment: .leading, spacing: 5) {
//                        Text("오늘의 분석")
//                        
//                        Text("전반부 페이스가 좋아졌습니다. ~~")
//                    }
//                    
//                    VStack(alignment: .leading, spacing: 5) {
//                        Text("다음 목표")
//                        
//                        Text("내일은 40개 도전해보세요")
//                    }
//                }
//            }
//            
//            HStack(spacing: 10) {
//                
//                Text("공유하기")
//                
//                Text("추가 예정")
//            }
//            
//            Button {
//                
//            } label: {
//                Text("홈으로 돌아가기")
//            }
//        }
//    }
//}

#Preview {
    ResultView(pushCount: 37) { _ in }
}
