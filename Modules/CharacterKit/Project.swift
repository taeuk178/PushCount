import ProjectDescription
import ProjectDescriptionHelpers

let targetVersion: String = "26.0"

let project = Project(
    name: "CharacterKit",
    targets: [
        .target(
            name: "CharacterKit",
            destinations: [.iPhone],
            product: .staticFramework,
            bundleId: "com.tuist.PushCount.CharacterKit",
            deploymentTargets: .iOS(targetVersion),
            infoPlist: .default,
            sources: [
                "Sources/**"
            ],
            dependencies: [
                .project(
                    target: "DesignSystemKit",
                    path: .relativeToRoot("Modules/DesignSystemKit")
                )
            ]
        )
    ]
)
