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
    @State private var elapsedSeconds: Int = 0
    @State private var isPaused = false
    @State private var isLocked = false
    @State private var showResultView = false
    
    private let targetCount = 50
    let exerciseTitle: String
    let onComplete: (Int) -> Void
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @Environment(\.dismiss) private var dismiss
    
    init(exerciseTitle: String = "PUSH UPS", onComplete: @escaping (Int) -> Void) {
        self.exerciseTitle = exerciseTitle
        self.onComplete = onComplete
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.black, Color(red: 0.14, green: 0.05, blue: 0.01), Color.black],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            Circle()
                .fill(Color(red: 1, green: 0.33, blue: 0).opacity(0.20))
                .frame(width: 520, height: 520)
                .blur(radius: 60)
                .offset(y: 100)
            
            VStack(spacing: 0) {
                headerView
                    .padding(.top, 20)
                    .padding(.horizontal, 24)
                
                mainCounterArea
                    .contentShape(Rectangle())
                    .onTapGesture {
                        guard !isPaused, !isLocked else { return }
                        pushCount += 1
                    }
                
                footerView
                    .padding(.horizontal, 24)
                    .padding(.bottom, 26)
                    .padding(.top, 14)
            }
        }
        .onReceive(timer) { _ in
            guard !isPaused else { return }
            elapsedSeconds += 1
        }
        .fullScreenCover(isPresented: $showResultView) {
            ResultView(pushCount: pushCount) { completedCount in
                showResultView = false
                onComplete(completedCount)
                dismiss()
            }
        }
    }
}

private extension ActionView {
    var headerView: some View {
        HStack {
            circleIconButton(systemName: "xmark") {
                showResultView = true
            }
            
            Spacer()
            
            VStack(spacing: 4) {
                Text(exerciseTitle)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color(red: 1, green: 0.33, blue: 0))
                
                Text("목표: \(targetCount) 회")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.white.opacity(0.65))
            }
            
            Spacer()
            
            circleIconButton(systemName: "gearshape.fill") {
            }
            .opacity(0.9)
        }
    }
    
    var mainCounterArea: some View {
        VStack(spacing: 26) {
            Text("탭해서 횟수 올리기")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.white.opacity(0.85))
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(Color.white.opacity(0.08))
                .clipShape(Capsule())
                .padding(.top, 36)
            
            ZStack {
                Circle()
                    .stroke(Color(red: 1, green: 0.33, blue: 0).opacity(0.22), lineWidth: 1)
                    .frame(width: 250, height: 250)
                
                Circle()
                    .stroke(Color(red: 1, green: 0.33, blue: 0).opacity(0.10), lineWidth: 1)
                    .frame(width: 320, height: 320)
                
                VStack(spacing: 6) {
                    Text("\(pushCount)")
                        .font(.system(size: 132, weight: .heavy))
                        .foregroundStyle(Color.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                    
                    Text("회 완료")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(Color(red: 1, green: 0.33, blue: 0))
                }
            }
            .padding(.top, 16)
            .padding(.bottom, 26)
            
            HStack(spacing: 48) {
                statBlock(title: "시간", value: formattedTime)
                statBlock(title: "평균 페이스", value: "\(formattedPace) 초")
            }
            .padding(.top, 8)
            
            Spacer(minLength: 0)
        }
    }
    
    var footerView: some View {
        VStack(spacing: 24) {
            HStack(spacing: 28) {
                smallActionButton(systemName: "stop.fill", title: "완료") {
                    showResultView = true
                }
                
                Button {
                    isPaused.toggle()
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color(red: 1, green: 0.33, blue: 0))
                            .frame(width: 94, height: 94)
                            .shadow(color: Color(red: 1, green: 0.33, blue: 0).opacity(0.4), radius: 16)
                        
                        Image(systemName: isPaused ? "play.fill" : "pause.fill")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundStyle(Color.white)
                    }
                }
                .buttonStyle(.plain)
                
                smallActionButton(systemName: isLocked ? "lock.fill" : "lock.open.fill", title: "잠금") {
                    isLocked.toggle()
                }
            }
        }
    }
    
    func statBlock(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Color.white.opacity(0.45))
            
            Text(value)
                .font(.system(size: 40, weight: .heavy))
                .foregroundStyle(Color.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }
    
    func circleIconButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Circle()
                .fill(Color.white.opacity(0.10))
                .frame(width: 40, height: 40)
                .overlay {
                    Image(systemName: systemName)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.white.opacity(0.88))
                }
        }
        .buttonStyle(.plain)
    }
    
    func smallActionButton(systemName: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Circle()
                    .fill(Color.white.opacity(0.08))
                    .frame(width: 48, height: 48)
                    .overlay {
                        Circle()
                            .stroke(Color.white.opacity(0.18), lineWidth: 2)
                    }
                    .overlay {
                        Image(systemName: systemName)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(Color.white.opacity(0.88))
                    }
                
                Text(title)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.white.opacity(0.55))
            }
        }
        .buttonStyle(.plain)
    }
    
    var formattedTime: String {
        let minutes = elapsedSeconds / 60
        let seconds = elapsedSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var formattedPace: String {
        guard pushCount > 0 else { return "0.0" }
        let pace = Double(elapsedSeconds) / Double(pushCount)
        return String(format: "%.1f", pace)
    }
}

#Preview {
    ActionView { count in
        print("Completed push count: \(count)")
    }
}
