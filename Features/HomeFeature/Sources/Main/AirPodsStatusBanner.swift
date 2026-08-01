//
//  AirPodsStatusBanner.swift
//  HomeFeature
//
//  Created by taeuk on 8/1/26.
//

import SwiftUI

import DesignSystemKit
import MotionKit

/// 메인 화면 상단에서 에어팟 착용 상태를 알려주는 배너.
struct AirPodsStatusBanner: View {

    let state: AirPodsMotionState
    let onOpenSettings: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: state.systemImageName)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(accentColor)
                .frame(width: 28, height: 28)
                .background(DesignColor.settingIconOverlay)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text(state.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(DesignColor.white)
                    .lineLimit(1)

                Text(state.message)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(DesignColor.white.opacity(0.6))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }

            Spacer(minLength: 0)

            if state == .unauthorized {
                Button("설정", action: onOpenSettings)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(DesignColor.brandOrange)
            } else if state != .worn {
                ProgressView()
                    .controlSize(.small)
                    .tint(DesignColor.white.opacity(0.5))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(DesignColor.settingCardOverlay)
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(accentColor.opacity(0.35), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .animation(.easeInOut(duration: 0.25), value: state)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(state.title). \(state.message)")
    }

    private var accentColor: Color {
        state == .worn ? DesignColor.successGreen : DesignColor.brandOrange
    }
}

#Preview {
    VStack(spacing: 12) {
        AirPodsStatusBanner(state: .worn) {}
        AirPodsStatusBanner(state: .notWorn) {}
        AirPodsStatusBanner(state: .disconnected) {}
        AirPodsStatusBanner(state: .unauthorized) {}
        AirPodsStatusBanner(state: .unsupported) {}
    }
    .padding(24)
    .background(DesignColor.black)
}
