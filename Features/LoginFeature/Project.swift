
import ProjectDescription

let targetVersion: String = "18.1"

let project = Project(
    name: "LoginFeature",
    targets: [
        .target(
            name: "LoginFeatureInterface",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: "com.tuist.PushCount.LoginFeatureInterface",
            deploymentTargets: .iOS(targetVersion),
            sources: ["Interface/**"],
            dependencies: [
                
            ]
        ),
        .target(
            name: "LoginFeature",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: "com.tuist.PushCount.LoginFeature",
            deploymentTargets: .iOS(targetVersion),
            sources: ["Sources/**"],
            dependencies: [
                .target(name: "LoginFeatureInterface"),
                .project(
                    target: "NetworkKit",
                    path: .relativeToRoot("Modules/NetworkKit")
                )
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
                .target(name: "LoginFeature"),
                .project(
                    target: "NetworkKit",
                    path: .relativeToRoot("Modules/NetworkKit")
                )
            ]
        )
    ]
)
