// swift-tools-version: 6.0
import PackageDescription

#if TUIST
    import struct ProjectDescription.PackageSettings

    let packageSettings = PackageSettings(
        // Customize the product types for specific package product
        // Default is .staticFramework
        // productTypes: ["Alamofire": .framework,]
        productTypes: [:]
    )
#endif

let package = Package(
    name: "PushCount",
    dependencies: [
        .package(
            url: "https://github.com/supabase/supabase-swift.git",
            from: "2.24.1"
        ),
        .package(
            url: "https://github.com/kakao/kakao-ios-sdk",
            from: "2.27.2"
        )
    ]
)
