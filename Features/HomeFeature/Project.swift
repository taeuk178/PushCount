
import ProjectDescription

let targetVersion: String = "18.1"

let project = Project(
    name: "HomeFeature",
    targets: [
        .target(
            name: "HomeFeatureInterface",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.tuist.PushCount.HomeFeatureInterface",
            deploymentTargets: .iOS(targetVersion),
            sources: ["Interface/**"],
            dependencies: [
                
            ]
        ),
        .target(
            name: "HomeFeature",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.tuist.PushCount.HomeFeature",
            deploymentTargets: .iOS(targetVersion),
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: [
                .target(name: "HomeFeatureInterface")
            ]
        ),
        .target(
            name: "HomeFeatureExample",
            destinations: .iOS,
            product: .app,
            bundleId: "com.tuist.PushCount.HomeFeatureExample",
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
                .target(name: "HomeFeature")
            ]
        )
    ]
)
