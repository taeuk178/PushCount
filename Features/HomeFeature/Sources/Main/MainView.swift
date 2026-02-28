import SwiftUI

import HomeFeatureInterface

public struct HomeView: View {
    
    public init() {}
    
    @State private var showingActionView = false
    @State private var todayPushCount = 0
    @State private var selectedExerciseIndex = 0
    
    private let exercises: [ExerciseCard] = [
        ExerciseCard(
            titleTop: "PUSH",
            titleBottom: "UPS",
            subtitle: "가슴 • 삼두 • 코어",
            intensity: "고강도",
            duration: "10분",
            colors: [Color(red: 0.06, green: 0.16, blue: 0.34), Color.black]
        ),
        ExerciseCard(
            titleTop: "PULL",
            titleBottom: "UPS",
            subtitle: "등 • 이두 • 코어",
            intensity: "중강도",
            duration: "12분",
            colors: [Color(red: 0.07, green: 0.25, blue: 0.30), Color.black]
        ),
        ExerciseCard(
            titleTop: "SQUAT",
            titleBottom: "SET",
            subtitle: "하체 • 둔근 • 코어",
            intensity: "고강도",
            duration: "15분",
            colors: [Color(red: 0.20, green: 0.14, blue: 0.08), Color.black]
        )
    ]
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            Color.black
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 32) {
                Text("오늘의 운동 시작해볼까요?")
                    .font(.system(size: 32, weight: .heavy))
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
                
                VStack(alignment: .leading, spacing: 20) {
                    TabView(selection: $selectedExerciseIndex) {
                        ForEach(Array(exercises.enumerated()), id: \.offset) { index, exercise in
                            ExerciseCardView(exercise: exercise)
                                .padding(.horizontal, 24)
                                .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .automatic))
                    .frame(height: UIScreen.main.bounds.height / 2)
                    
                    VStack(spacing: 12) {
                        Text("선택된 운동: \(exercises[selectedExerciseIndex].displayName)")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color(red: 1, green: 0.55, blue: 0.35))
                        
                        Button {
                            showingActionView = true
                        } label: {
                            HStack(spacing: 8) {
                                Text("시작하기")
                                Image(systemName: "play.fill")
                                    .font(.system(size: 15, weight: .bold))
                            }
                            .frame(width: 210, height: 64)
                            .font(.system(size: 28, weight: .heavy))
                            .foregroundStyle(Color.white)
                            .background(Color(red: 1, green: 0.33, blue: 0))
                            .clipShape(Capsule())
                            .shadow(color: Color(red: 1, green: 0.33, blue: 0).opacity(0.45), radius: 16)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                    Spacer()
                }
            }
        }
        .fullScreenCover(isPresented: $showingActionView) {
            ActionView(exerciseTitle: exercises[selectedExerciseIndex].displayName) { completedPushCount in
                todayPushCount += completedPushCount
            }
        }
    }
}

private struct ExerciseCardView: View {
    
    let exercise: ExerciseCard
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 26)
                .fill(
                    LinearGradient(
                        colors: exercise.colors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 26)
                        .stroke(Color(red: 1, green: 0.33, blue: 0).opacity(0.6), lineWidth: 1)
                }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(exercise.titleTop)
                    .font(.system(size: 56, weight: .black))
                    .foregroundStyle(Color.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                
                Text(exercise.titleBottom)
                    .font(.system(size: 56, weight: .black))
                    .foregroundStyle(Color(red: 1, green: 0.33, blue: 0))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                
                VStack(alignment: .leading, spacing: 14) {
                    Text(exercise.subtitle)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color(red: 0.82, green: 0.84, blue: 0.87))
                    
                    HStack(spacing: 12) {
                        Label(exercise.intensity, systemImage: "flame.fill")
                            .foregroundStyle(Color(red: 1, green: 0.33, blue: 0))
                        Label(exercise.duration, systemImage: "timer")
                            .foregroundStyle(Color(red: 1, green: 0.33, blue: 0))
                    }
                    .font(.system(size: 14, weight: .semibold))
                }
            }
            .padding(24)
        }
    }
}

private struct ExerciseCard {
    let titleTop: String
    let titleBottom: String
    let subtitle: String
    let intensity: String
    let duration: String
    let colors: [Color]
    
    var displayName: String {
        "\(titleTop) \(titleBottom)"
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
