
import SwiftUI
import RecordFeatureInterface
import DesignSystemKit

public struct RecordView: View {

    // TODO: 데이터 영속화 후 실제 기록으로 교체
    private let records: [WorkoutRecord] = [
        .init(date: "10월 24일 목요일", title: "푸시업", reps: 50, duration: "12:45", calories: 16),
        .init(date: "10월 23일 수요일", title: "푸시업", reps: 37, duration: "09:18", calories: 12),
        .init(date: "10월 22일 화요일", title: "푸시업", reps: 41, duration: "10:26", calories: 13),
        .init(date: "10월 21일 월요일", title: "푸시업", reps: 29, duration: "07:42", calories: 9)
    ]

    public var body: some View {
        ZStack {
            DesignColor.canvas
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: DesignSpacing.lg) {
                    VStack(alignment: .leading, spacing: DesignSpacing.xs) {
                        Text("기록")
                            .font(DesignFont.display)
                            .foregroundStyle(DesignColor.ink)

                        Text("지금까지 \(totalReps)회 해냈어요")
                            .font(DesignFont.body)
                            .foregroundStyle(DesignColor.inkMuted)
                    }

                    summary

                    VStack(alignment: .leading, spacing: DesignSpacing.sm) {
                        Text("최근 운동")
                            .font(DesignFont.title)
                            .foregroundStyle(DesignColor.ink)

                        ForEach(records) { record in
                            historyCard(record: record)
                        }
                    }
                }
                .padding(.horizontal, DesignSpacing.screen)
                .padding(.top, DesignSpacing.md)
                .padding(.bottom, DesignSpacing.xl)
            }
        }
    }

    private var totalReps: Int {
        records.map(\.reps).reduce(0, +)
    }
}

private extension RecordView {

    var summary: some View {
        DSCard(padding: DesignSpacing.md) {
            HStack(spacing: 0) {
                DSStat(value: "\(records.count)", label: "운동 횟수")

                divider

                DSStat(value: "\(totalReps)", label: "총 개수")

                divider

                DSStat(value: "약 \(records.map(\.calories).reduce(0, +))", label: "칼로리")
            }
        }
    }

    var divider: some View {
        Rectangle()
            .fill(DesignColor.line)
            .frame(width: 1, height: 32)
    }

    func historyCard(record: WorkoutRecord) -> some View {
        DSCard(padding: DesignSpacing.md) {
            HStack(spacing: DesignSpacing.md) {
                Image(systemName: "figure.strengthtraining.traditional")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(DesignColor.push.deep)
                    .frame(width: 46, height: 46)
                    .background(DesignColor.push.soft, in: RoundedRectangle(cornerRadius: DesignRadius.sm, style: .continuous))

                VStack(alignment: .leading, spacing: DesignSpacing.xs) {
                    HStack(alignment: .firstTextBaseline, spacing: DesignSpacing.xs) {
                        Text("\(record.reps)")
                            .font(DesignFont.numeric(24))
                            .foregroundStyle(DesignColor.ink)

                        Text("회")
                            .font(DesignFont.label)
                            .foregroundStyle(DesignColor.inkMuted)
                    }

                    Text(record.date)
                        .font(DesignFont.label)
                        .foregroundStyle(DesignColor.inkMuted)
                        .lineLimit(1)
                }

                Spacer(minLength: 0)

                VStack(alignment: .trailing, spacing: DesignSpacing.xs) {
                    DSPill(record.duration, systemImage: "timer", palette: DesignColor.pull)
                    DSPill("약 \(record.calories)kcal", systemImage: "flame.fill", palette: DesignColor.sunny)
                }
            }
        }
    }
}

#Preview {
    RecordView()
}
