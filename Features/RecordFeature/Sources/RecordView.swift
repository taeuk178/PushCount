
import SwiftUI
import RecordFeatureInterface

public struct RecordView: View {
    
    private let records: [WorkoutRecord] = [
        .init(date: "10월 24일 목요일", title: "푸시업", reps: 50, duration: "12:45", calories: 16),
        .init(date: "10월 23일 수요일", title: "푸시업", reps: 37, duration: "09:18", calories: 12),
        .init(date: "10월 22일 화요일", title: "푸시업", reps: 41, duration: "10:26", calories: 13),
        .init(date: "10월 21일 월요일", title: "푸시업", reps: 29, duration: "07:42", calories: 9)
    ]
    
    public var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("활동 기록")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Color(red: 1, green: 0.33, blue: 0))
                        .tracking(1.2)
                    
                    Text("히스토리")
                        .font(.system(size: 32, weight: .heavy))
                        .foregroundStyle(.white)
                    
                    Text("최근 운동 결과를 한눈에 확인하세요")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color(red: 0.61, green: 0.64, blue: 0.69))
                }
                
                HStack(spacing: 12) {
                    summaryCard(title: "총 운동", value: "\(records.count)회")
                    summaryCard(title: "총 횟수", value: "\(records.map(\.reps).reduce(0, +))회")
                    summaryCard(title: "칼로리", value: "\(records.map(\.calories).reduce(0, +))kcal")
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("기록 목록")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                    
                    ForEach(records) { record in
                        historyCard(record: record)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 52)
            .padding(.bottom, 28)
        }
    }
    
    private func summaryCard(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Color.white.opacity(0.5))
            
            Text(value)
                .font(.system(size: 20, weight: .heavy))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 14)
        .background(Color.white.opacity(0.06))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func historyCard(record: WorkoutRecord) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(record.title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                    
                    Text(record.date)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.white.opacity(0.48))
                }
                
                Spacer()
                
                Text("완료")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color(red: 1, green: 0.33, blue: 0))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color(red: 1, green: 0.33, blue: 0).opacity(0.14))
                    .clipShape(Capsule())
            }
            
            HStack(spacing: 12) {
                metricPill(icon: "figure.strengthtraining.traditional", text: "\(record.reps)회")
                metricPill(icon: "timer", text: record.duration)
                metricPill(icon: "flame.fill", text: "\(record.calories)kcal")
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.05))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(red: 1, green: 0.33, blue: 0).opacity(0.28), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
    
    private func metricPill(icon: String, text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .bold))
            Text(text)
                .font(.system(size: 12, weight: .semibold))
        }
        .foregroundStyle(Color(red: 1, green: 0.33, blue: 0))
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color(red: 1, green: 0.33, blue: 0).opacity(0.12))
        .clipShape(Capsule())
    }
}
