
import ProjectDescription

let targetVersion: String = "26.0"

let project = Project(
    name: "HomeFeature",
    targets: [
        .target(
            name: "HomeFeatureInterface",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: "com.tuist.PushCount.HomeFeatureInterface",
            deploymentTargets: .iOS(targetVersion),
            sources: ["Interface/**"],
            dependencies: [
                
            ]
        ),
        .target(
            name: "HomeFeature",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: "com.tuist.PushCount.HomeFeature",
            deploymentTargets: .iOS(targetVersion),
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: [
                .target(name: "HomeFeatureInterface"),
                .project(
                    target: "DesignSystemKit",
                    path: .relativeToRoot("Modules/DesignSystemKit")
                ),
                .project(
                    target: "MotionKit",
                    path: .relativeToRoot("Modules/MotionKit")
                )
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
                    "NSMotionUsageDescription": "에어팟의 움직임으로 운동 횟수를 자동으로 세기 위해 동작 데이터를 사용합니다.",
                ]
            ),
            sources: ["Example/**"],
            dependencies: [
                .target(name: "HomeFeature")
            ]
        )
    ]
)
