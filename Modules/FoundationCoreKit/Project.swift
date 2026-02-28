import ProjectDescription

let targetVersion: String = "18.1"

let project = Project(
    name: "FoundationCoreKit",
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
