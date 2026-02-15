
import ProjectDescription

let targetVersion: String = "18.1"

let project = Project(
    name: "RecordFeature",
    targets: [
        .target(
            name: "RecordFeatureInterface",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.tuist.PushCount.RecordFeatureInterface",
            deploymentTargets: .iOS(targetVersion),
            sources: ["Interface/**"],
            dependencies: [
                
            ]
        ),
        .target(
            name: "RecordFeature",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.tuist.PushCount.RecordFeature",
            deploymentTargets: .iOS(targetVersion),
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: [
                .target(name: "RecordFeatureInterface") 
            ]
        ),
        .target(
            name: "RecordFeatureExample",
            destinations: .iOS,
            product: .app,
            bundleId: "com.tuist.PushCount.RecordFeatureExample",
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
                .target(name: "RecordFeature")
            ]
        )
    ]
)
