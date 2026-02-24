
import ProjectDescription

let targetVersion: String = "18.1"

let project = Project(
    name: "LoginFeature",
    targets: [
        .target(
            name: "LoginFeatureInterface",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.tuist.PushCount.LoginFeatureInterface",
            deploymentTargets: .iOS(targetVersion),
            sources: ["Interface/**"],
            dependencies: [
                
            ]
        ),
        .target(
            name: "LoginFeature",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.tuist.PushCount.LoginFeature",
            deploymentTargets: .iOS(targetVersion),
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: [
                .target(name: "LoginFeatureInterface"),
                .project(target: "NetworkKit", path: "../../Modules/NetworkKit"),
                .external(name: "KakaoSDKUser"),
                .external(name: "KakaoSDKAuth")
            ]
        ),
        .target(
            name: "LoginFeatureExample",
            destinations: .iOS,
            product: .app,
            bundleId: "com.tuist.PushCount.LoginFeatureExample",
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
                .target(name: "LoginFeature")
            ]
        )
    ]
)
