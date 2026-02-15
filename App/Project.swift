import ProjectDescription

let targetVersion: String = "18.1"

let project = Project(
    name: "PushCount",
    targets: [
        .target(
            name: "Shared",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.tuist.PushCount.Shared",
            deploymentTargets: .iOS(targetVersion),
            sources: ["Shared/**"],
            dependencies: []
        ),
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
                ]
            ),
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: [
                .target(name: "Shared"),
                .project(
                    target: "SettingFeature",
                    path: "../Features/SettingFeature"
                ),
                .project(
                    target: "MainFeature",
                    path: "../Features/MainFeature"
                ),
                .project(
                    target: "RecordFeature",
                    path: "../Features/RecordFeature"
                )
            ]
        )
    ]
)
