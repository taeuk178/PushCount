import ProjectDescription
import ProjectDescriptionHelpers

let targetVersion: String = "26.0"

let project = Project(
    name: "MotionKit",
    settings: .automaticSigning,
    targets: [
        .target(
            name: "MotionKit",
            destinations: [.iPhone],
            product: .staticFramework,
            bundleId: "com.tuist.PushCount.MotionKit",
            deploymentTargets: .iOS(targetVersion),
            infoPlist: .default,
            sources: [
                "Sources/**"
            ],
            dependencies: [
                .project(
                    target: "FoundationCoreKit",
                    path: .relativeToRoot("Modules/FoundationCoreKit")
                )
            ]
        )
    ]
)
