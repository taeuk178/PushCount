import ProjectDescription

let targetVersion: String = "18.1"

let project = Project(
    name: "NetworkKit",
    targets: [
        .target(
            name: "NetworkKit",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: "com.tuist.PushCount.NetworkKit",
            deploymentTargets: .iOS(targetVersion),
            sources: ["Sources/**"],
            dependencies: [
                .external(name: "Supabase", condition: .none),
                .external(name: "KakaoSDKUser", condition: .none),
                .external(name: "KakaoSDKAuth", condition: .none),
                .project(
                    target: "FoundationCoreKit",
                    path: .relativeToRoot("Modules/FoundationCoreKit")
                )
            ]
        )
    ]
)
