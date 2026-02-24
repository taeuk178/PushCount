import ProjectDescription

let targetVersion: String = "18.1"

let project = Project(
    name: "NetworkKit",
    targets: [
        .target(
            name: "NetworkKit",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.tuist.PushCount.NetworkKit",
            deploymentTargets: .iOS(targetVersion),
            sources: ["Sources/**"],
            dependencies: [
                .external(name: "Supabase"),
                .external(name: "KakaoSDKUser"),
                .external(name: "KakaoSDKAuth")
            ]
        )
    ]
)
