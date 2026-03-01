import Foundation
import Supabase
import AuthenticationServices
import CryptoKit
import UIKit
import Security

public final class AuthService {
    public static let shared = AuthService()

    public let appleSignIn = AppleSignInService.shared

    private let client = SupabaseKeyValue.client
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
//            .maybeSingle()
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

// MARK: - Apple Sign In

public struct AppleSignInUser {
    public let userId: String
    public let email: String?
    public let name: String?
    public let idToken: String
    public let rawNonce: String
}

public enum AppleSignInError: LocalizedError {
    case missingPresentationAnchor
    case invalidCredential
    case missingIdentityToken
    case invalidIdentityToken
    case cancelled
    case unknownAuthorizationError(code: Int, description: String)

    public var errorDescription: String? {
        switch self {
        case .missingPresentationAnchor:
            return "Apple 로그인 창을 표시할 수 없습니다."
        case .invalidCredential:
            return "Apple 인증 정보를 가져올 수 없습니다."
        case .missingIdentityToken:
            return "Apple ID 토큰이 없습니다."
        case .invalidIdentityToken:
            return "Apple ID 토큰 형식이 올바르지 않습니다."
        case .cancelled:
            return "사용자가 Apple 로그인을 취소했습니다."
        case let .unknownAuthorizationError(code, description):
            return "Apple 로그인 실패(코드 \(code)): \(description)"
        }
    }
}

public final class AppleSignInService: NSObject {
    public static let shared = AppleSignInService()

    private var continuation: CheckedContinuation<AppleSignInUser, Error>?
    private var currentNonce: String?

    private override init() {
        super.init()
    }

    @MainActor
    public func signIn() async throws -> AppleSignInUser {
        guard continuation == nil else {
            throw NSError(domain: "AppleSignInService", code: -1, userInfo: [NSLocalizedDescriptionKey: "이미 로그인 요청이 진행 중입니다."])
        }

        guard hasPresentationAnchor else {
            throw AppleSignInError.missingPresentationAnchor
        }

        let nonce = randomNonceString()
        currentNonce = nonce

        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self

        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            controller.performRequests()
        }
    }

    private var hasPresentationAnchor: Bool {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .contains { $0.isKeyWindow }
    }

    private func randomNonceString(length: Int = 32) -> String {
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0..<16).map { _ in
                var random: UInt8 = 0
                let status = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if status != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(status)")
                }
                return random
            }

            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.map { String(format: "%02x", $0) }.joined()
    }

    private func buildName(from fullName: PersonNameComponents?) -> String? {
        guard let fullName else { return nil }
        let formatter = PersonNameComponentsFormatter()
        formatter.style = .default
        let formatted = formatter.string(from: fullName).trimmingCharacters(in: .whitespacesAndNewlines)
        return formatted.isEmpty ? nil : formatted
    }

    private func complete(with result: Result<AppleSignInUser, Error>) {
        switch result {
        case .success(let user):
            continuation?.resume(returning: user)
        case .failure(let error):
            continuation?.resume(throwing: error)
        }
        continuation = nil
        currentNonce = nil
    }
}

extension AppleSignInService: ASAuthorizationControllerDelegate {
    public func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            complete(with: .failure(AppleSignInError.invalidCredential))
            return
        }

        guard let tokenData = credential.identityToken else {
            complete(with: .failure(AppleSignInError.missingIdentityToken))
            return
        }

        guard let tokenString = String(data: tokenData, encoding: .utf8) else {
            complete(with: .failure(AppleSignInError.invalidIdentityToken))
            return
        }

        guard let nonce = currentNonce else {
            complete(with: .failure(AppleSignInError.invalidCredential))
            return
        }

        let user = AppleSignInUser(
            userId: credential.user,
            email: credential.email,
            name: buildName(from: credential.fullName),
            idToken: tokenString,
            rawNonce: nonce
        )

        complete(with: .success(user))
    }

    public func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        let nsError = error as NSError
        print("Apple Sign In error - domain: \(nsError.domain), code: \(nsError.code), description: \(nsError.localizedDescription)")

        if nsError.domain == ASAuthorizationError.errorDomain,
           nsError.code == ASAuthorizationError.canceled.rawValue {
            complete(with: .failure(AppleSignInError.cancelled))
            return
        }

        if nsError.domain == ASAuthorizationError.errorDomain,
           nsError.code == ASAuthorizationError.unknown.rawValue {
            complete(
                with: .failure(
                    AppleSignInError.unknownAuthorizationError(
                        code: nsError.code,
                        description: "Unknown error. Sign in with Apple capability/entitlement, Team/Bundle ID 설정, 기기의 Apple ID 로그인 상태를 확인하세요."
                    )
                )
            )
            return
        }

        complete(with: .failure(error))
    }
}

extension AppleSignInService: ASAuthorizationControllerPresentationContextProviding {
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        if let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap(\.windows)
            .first(where: \.isKeyWindow) {
            return window
        }

        return ASPresentationAnchor()
    }
}
