
import ProjectDescription

let targetVersion: String = "18.1"

let project = Project(
    name: "MainFeature",
    targets: [
        .target(
            name: "MainFeatureInterface",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.tuist.PushCount.MainFeatureInterface",
            deploymentTargets: .iOS(targetVersion),
            sources: ["Interface/**"],
            dependencies: [
                
            ]
        ),
        .target(
            name: "MainFeature",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.tuist.PushCount.MainFeature",
            deploymentTargets: .iOS(targetVersion),
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: [
                .target(name: "MainFeatureInterface"),
                .project(target: "Shared", path: "../../App")
            ]
        ),
        .target(
            name: "MainFeatureExample",
            destinations: .iOS,
            product: .app,
            bundleId: "com.tuist.PushCount.MainFeatureExample",
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
                .target(name: "MainFeature")
            ]
        )
    ]
)
