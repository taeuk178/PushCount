import Foundation

public struct User: Codable, Identifiable {
    public let id: UUID
    public let userId: String
    public let provider: AuthProvider
    public let email: String?
    public let name: String?
    public let profileImageUrl: String?
    public let createdAt: Date
    public let updatedAt: Date
    public let lastLoginAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case provider
        case email
        case name
        case profileImageUrl = "profile_image_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case lastLoginAt = "last_login_at"
    }

    public init(
        id: UUID = UUID(),
        userId: String,
        provider: AuthProvider,
        email: String? = nil,
        name: String? = nil,
        profileImageUrl: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        lastLoginAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.provider = provider
        self.email = email
        self.name = name
        self.profileImageUrl = profileImageUrl
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.lastLoginAt = lastLoginAt
    }
}

public enum AuthProvider: String, Codable {
    case kakao
    case apple
}

// 사용자 생성/업데이트용 DTO
public struct UserUpsertRequest: Codable {
    public let userId: String
    public let provider: AuthProvider
    public let email: String?
    public let name: String?
    public let profileImageUrl: String?
    public let lastLoginAt: Date

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case provider
        case email
        case name
        case profileImageUrl = "profile_image_url"
        case lastLoginAt = "last_login_at"
    }

    public init(
        userId: String,
        provider: AuthProvider,
        email: String? = nil,
        name: String? = nil,
        profileImageUrl: String? = nil,
        lastLoginAt: Date = Date()
    ) {
        self.userId = userId
        self.provider = provider
        self.email = email
        self.name = name
        self.profileImageUrl = profileImageUrl
        self.lastLoginAt = lastLoginAt
    }
}
