import ProjectDescription
import ProjectDescriptionHelpers

let targetVersion: String = "26.0"

let project = Project(
    name: "PushCount",
    settings: .automaticSigning,
    targets: [
        .target(
            name: "PushCount",
            destinations: .iOS,
            product: .app,
            bundleId: "com.tuist.PushCount",
            deploymentTargets: .iOS(targetVersion),
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                    "NSMotionUsageDescription": "에어팟의 움직임으로 운동 횟수를 자동으로 세기 위해 동작 데이터를 사용합니다.",
                ]
            ),
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: [
                .project(
                    target: "SettingFeature",
                    path: "../Features/SettingFeature"
                ),
                .project(
                    target: "HomeFeature",
                    path: "../Features/HomeFeature"
                ),
                .project(
                    target: "RecordFeature",
                    path: "../Features/RecordFeature"
                ),
                .project(
                    target: "LoginFeature",
                    path: "../Features/LoginFeature"
                )
            ]
        )
    ]
)
