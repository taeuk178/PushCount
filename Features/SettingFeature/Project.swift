import ProjectDescription

let targetVersion: String = "18.1"

let project = Project(
    name: "SettingFeature",
    targets: [
        .target(
            name: "SettingFeatureInterface",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: "com.tuist.PushCount.SettingFeatureInterface",
            deploymentTargets: .iOS(targetVersion),
            sources: ["Interface/**"],
            dependencies: []
        ),
        .target(
            name: "SettingFeature",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: "com.tuist.PushCount.SettingFeature",
            deploymentTargets: .iOS(targetVersion),
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: [
                .target(name: "SettingFeatureInterface"),
                .project(
                    target: "DesignSystemKit",
                    path: .relativeToRoot("Modules/DesignSystemKit")
                )
            ]
        ),
        .target(
            name: "SettingFeatureExample",
            destinations: .iOS,
            product: .app,
            bundleId: "com.tuist.PushCount.SettingFeatureExample",
            deploymentTargets: .iOS(targetVersion),
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                ]
            ),
            sources: ["Example/**"],
            dependencies: [
                .target(name: "SettingFeature")
            ]
        )
    ]
)
