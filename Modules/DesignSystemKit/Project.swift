import ProjectDescription
import ProjectDescriptionHelpers

let targetVersion: String = "18.1"

let project = Project(
    name: "DesignSystemKit",
    targets: [
        .target(
            name: "DesignSystemKit",
            destinations: [.iPhone],
            product: .staticFramework,
            bundleId: "com.tuist.PushCount.DesignSystemKit",
            deploymentTargets: .iOS(targetVersion),
            infoPlist: .default,
            sources: [
                "Sources/**"
            ],
            dependencies: [
                
            ]
        )
    ]
)
