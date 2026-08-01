import ProjectDescription

public extension Settings {

    static var automaticSigning: Settings {
        .settings(
            base: [
                "CODE_SIGN_STYLE": "Automatic",
                "DEVELOPMENT_TEAM": "S63RBKT6UQ"
            ]
        )
    }
}
