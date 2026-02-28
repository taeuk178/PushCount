//
//  ResultView.swift
//  HomeFeature
//
//  Created by taeuk on 8/30/25.
//

import SwiftUI
import HomeFeatureInterface
import DesignSystemKit

struct ResultView: View {
    
    let pushCount: Int
    let onDismiss: (Int) -> Void
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [DesignColor.black, DesignColor.deepOrangeBackgroundStrong, DesignColor.black],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            Circle()
                .fill(DesignColor.brandOrange.opacity(0.16))
                .frame(width: 360, height: 360)
                .blur(radius: 40)
                .offset(x: 110, y: 190)
            
            Circle()
                .fill(DesignColor.brandOrange.opacity(0.08))
                .frame(width: 260, height: 260)
                .blur(radius: 30)
                .offset(x: -120, y: -170)
            
            VStack(spacing: 0) {
                headerView
                
                Spacer()
                
                centerSummaryView
                
                metricsGrid
                    .padding(.top, 30)
                
                Spacer()
                
                footerView
                    .padding(.bottom, 28)
            }
            .padding(.horizontal, 24)
            .padding(.top, 48)
        }
    }
}

private extension ResultView {
    var headerView: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("운동 결과 요약")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(DesignColor.brandOrange)
                    .tracking(1.2)
                
                Text("수고하셨습니다!")
                    .font(.system(size: 26, weight: .heavy))
                    .foregroundStyle(DesignColor.white)
                
                Text("\(formatDateInKorean(Date())) • 맨몸 운동")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(DesignColor.slate400)
            }
            
            Spacer()
            
            Button {
                onDismiss(pushCount)
            } label: {
                Circle()
                    .fill(DesignColor.white.opacity(0.10))
                    .frame(width: 40, height: 40)
                    .overlay {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(DesignColor.white.opacity(0.9))
                    }
            }
            .buttonStyle(.plain)
        }
    }
    
    var centerSummaryView: some View {
        VStack(spacing: 8) {
            Text("\(pushCount)")
                .font(.system(size: 120, weight: .black))
                .foregroundStyle(
                    LinearGradient(
                        colors: [DesignColor.brandOrangeGradientStart, DesignColor.brandOrangeGradientEnd],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            
            Text("총 횟수 (푸시업)")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(DesignColor.slate400)
                .tracking(0.6)
        }
    }
    
    var metricsGrid: some View {
        let duration = workoutDurationString()
        let calories = calculateCalories(pushCount: pushCount)
        let pace = calculatePerMinute(pushCount: pushCount, durationString: duration)
        let heartRate = estimatedHeartRate(pushCount: pushCount)
        
        return VStack(spacing: 24) {
            HStack(spacing: 24) {
                metricItem(value: duration, label: "운동 시간")
                metricItem(value: "\(calories)", label: "소모 칼로리")
            }
            
            HStack(spacing: 24) {
                metricItem(value: String(format: "%.1f", pace), label: "분당 횟수")
                metricItem(value: "\(heartRate)", label: "평균 심박수")
            }
        }
    }
    
    func metricItem(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 34, weight: .heavy))
                .foregroundStyle(DesignColor.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            
            Text(label)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(DesignColor.slate500)
        }
        .frame(maxWidth: .infinity)
    }
    
    var footerView: some View {
        VStack(spacing: 14) {
            Button {
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "square.and.arrow.up")
                    Text("친구에게 공유하기")
                }
                .frame(maxWidth: .infinity)
                .frame(height: 58)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(DesignColor.white)
                .background(DesignColor.clear)
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(DesignColor.white.opacity(0.18), lineWidth: 1)
                }
            }
            .buttonStyle(.plain)
            
            Button {
                onDismiss(pushCount)
            } label: {
                HStack(spacing: 8) {
                    Text("완료")
                    Image(systemName: "chevron.right")
                }
                .frame(maxWidth: .infinity)
                .frame(height: 66)
                .font(.system(size: 22, weight: .black))
                .foregroundStyle(DesignColor.black.opacity(0.85))
                .background(DesignColor.brandOrange)
                .clipShape(Capsule())
                .shadow(color: DesignColor.brandOrange.opacity(0.35), radius: 16)
            }
        }
    }
}

extension ResultView {
    
    private func formatDateInKorean(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일 EEEE"
        return formatter.string(from: date)
    }
    
    private func calculateCalories(pushCount: Int) -> Int {
        let caloriesPerPushUp = 0.32
        return max(Int(Double(pushCount) * caloriesPerPushUp), 1)
    }
    
    private func workoutDurationString() -> String {
        let seconds = max(pushCount * 3, 60)
        let minutesPart = seconds / 60
        let secondsPart = seconds % 60
        return String(format: "%02d:%02d", minutesPart, secondsPart)
    }
    
    private func calculatePerMinute(pushCount: Int, durationString: String) -> Double {
        let parts = durationString.split(separator: ":")
        guard parts.count == 2,
              let minutes = Double(parts[0]),
              let seconds = Double(parts[1]) else { return 0 }
        let totalMinutes = max((minutes * 60 + seconds) / 60, 0.1)
        return Double(pushCount) / totalMinutes
    }
    
    private func estimatedHeartRate(pushCount: Int) -> Int {
        min(110 + Int(Double(pushCount) * 0.7), 185)
    }
}

#Preview {
    ResultView(pushCount: 37) { _ in }
}
