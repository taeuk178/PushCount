import ProjectDescription
import ProjectDescriptionHelpers

let targetVersion: String = "26.0"

let project = Project(
    name: "FoundationCoreKit",
    settings: .automaticSigning,
    targets: [
        .target(
            name: "FoundationCoreKit",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: "com.tuist.PushCount.FoundationCoreKit",
            deploymentTargets: .iOS(targetVersion),
            sources: ["Sources/**"],
            dependencies: [
                
            ]
        )
    ]
)
