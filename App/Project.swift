import ProjectDescription

let targetVersion: String = "18.1"

let project = Project(
    name: "PushCount",
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
                ]
            ),
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: [
                .external(name: "Supabase", condition: .none),
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
