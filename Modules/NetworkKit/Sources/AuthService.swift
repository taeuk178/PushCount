import Foundation
import Supabase

public final class AuthService {
    public static let shared = AuthService()

    private let client = SupabaseClient.shared.client
    private let tableName = "users"

    private init() {}

    // MARK: - 사용자 저장/업데이트 (Upsert)

    /// 카카오 또는 애플 로그인 후 사용자 정보를 Supabase에 저장/업데이트
    public func upsertUser(_ request: UserUpsertRequest) async throws -> User {
        // Supabase의 upsert 기능 사용
        // user_id가 이미 존재하면 업데이트, 없으면 삽입
        let response: User = try await client
            .from(tableName)
            .upsert(request, onConflict: "user_id")
            .select()
            .single()
            .execute()
            .value

        return response
    }

    // MARK: - 사용자 조회

    /// user_id로 사용자 조회
    public func getUser(byUserId userId: String) async throws -> User? {
        let response: [User] = try await client
            .from(tableName)
            .select()
            .eq("user_id", value: userId)
            .execute()
            .value

        return response.first
    }

    /// UUID로 사용자 조회
    public func getUser(byId id: UUID) async throws -> User? {
        let response: User? = try await client
            .from(tableName)
            .select()
            .eq("id", value: id.uuidString)
            .maybeSingle()
            .execute()
            .value

        return response
    }

    // MARK: - 로그인 시간 업데이트

    /// 마지막 로그인 시간 업데이트
    public func updateLastLogin(userId: String) async throws {
        struct LastLoginUpdate: Codable {
            let lastLoginAt: Date

            enum CodingKeys: String, CodingKey {
                case lastLoginAt = "last_login_at"
            }
        }

        try await client
            .from(tableName)
            .update(LastLoginUpdate(lastLoginAt: Date()))
            .eq("user_id", value: userId)
            .execute()
    }
}
