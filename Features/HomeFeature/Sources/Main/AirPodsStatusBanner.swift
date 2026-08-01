//
//  AirPodsStatusBanner.swift
//  HomeFeature
//
//  Created by taeuk on 8/1/26.
//

import SwiftUI

import DesignSystemKit
import MotionKit

/// 홈 화면에서 에어팟 착용 상태를 알려주는 배너.
struct AirPodsStatusBanner: View {

    let state: AirPodsMotionState
    let onOpenSettings: () -> Void

    var body: some View {
        HStack(spacing: DesignSpacing.sm) {
            Image(systemName: state.systemImageName)
                .font(DesignFont.label)
                .foregroundStyle(palette.deep)
                .frame(width: 32, height: 32)
                .background(palette.soft, in: Circle())

            VStack(alignment: .leading, spacing: 1) {
                Text(state.title)
                    .font(DesignFont.label)
                    .foregroundStyle(DesignColor.ink)
                    .lineLimit(1)

                Text(state.message)
                    .font(DesignFont.caption)
                    .foregroundStyle(DesignColor.inkMuted)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }

            Spacer(minLength: 0)

            switch state {
            case .unauthorized:
                Button("설정", action: onOpenSettings)
                    .font(DesignFont.label)
                    .foregroundStyle(DesignColor.brand.deep)

            case .disconnected, .notWorn:
                // 사용자가 조치하면 곧 풀리는 상태에서만 돌린다. `unsupported` 는
                // 기다린다고 바뀌지 않으므로 계속 도는 인디케이터가 오해를 준다.
                ProgressView()
                    .controlSize(.small)
                    .tint(DesignColor.inkMuted)

            case .worn, .unsupported:
                EmptyView()
            }
        }
        .padding(DesignSpacing.sm)
        .background(DesignColor.surface, in: RoundedRectangle(cornerRadius: DesignRadius.md, style: .continuous))
        .shadow(color: DesignColor.ink.opacity(0.05), radius: 8, y: 2)
        .animation(.easeInOut(duration: 0.25), value: state)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(state.title). \(state.message)")
    }

    private var palette: DesignPalette {
        state == .worn ? DesignColor.success : DesignColor.sunny
    }
}

#Preview {
    VStack(spacing: DesignSpacing.sm) {
        AirPodsStatusBanner(state: .worn) {}
        AirPodsStatusBanner(state: .notWorn) {}
        AirPodsStatusBanner(state: .disconnected) {}
        AirPodsStatusBanner(state: .unauthorized) {}
        AirPodsStatusBanner(state: .unsupported) {}
    }
    .padding(DesignSpacing.screen)
    .background(DesignColor.canvas)
}
