import Foundation
import KakaoSDKUser
import KakaoSDKAuth
import AuthenticationServices

@MainActor
@Observable
public final class LoginViewModel: NSObject {

    public var isLoading = false
    public var errorMessage: String?
    public var isLoggedIn = false

    public override init() {
        super.init()
    }

    // MARK: - 카카오 로그인

    public func loginWithKakao() {
        isLoading = true
        errorMessage = nil

        // 카카오톡 앱이 설치되어 있는지 확인
        if UserApi.isKakaoTalkLoginAvailable() {
            // 카카오톡으로 로그인
            loginWithKakaoTalk()
        } else {
            // 카카오 계정으로 로그인 (웹)
            loginWithKakaoAccount()
        }
    }

    private func loginWithKakaoTalk() {
        UserApi.shared.loginWithKakaoTalk { [weak self] oauthToken, error in
            guard let self = self else { return }

            Task { @MainActor in
                self.isLoading = false

                if let error = error {
                    self.errorMessage = "카카오 로그인 실패: \(error.localizedDescription)"
                    return
                }

                if oauthToken != nil {
                    // 사용자 정보 가져오기
                    await self.fetchKakaoUserInfo()
                }
            }
        }
    }

    private func loginWithKakaoAccount() {
        UserApi.shared.loginWithKakaoAccount { [weak self] oauthToken, error in
            guard let self = self else { return }

            Task { @MainActor in
                self.isLoading = false

                if let error = error {
                    self.errorMessage = "카카오 로그인 실패: \(error.localizedDescription)"
                    return
                }

                if oauthToken != nil {
                    // 사용자 정보 가져오기
                    await self.fetchKakaoUserInfo()
                }
            }
        }
    }

    private func fetchKakaoUserInfo() async {
        UserApi.shared.me { [weak self] user, error in
            guard let self = self else { return }

            Task { @MainActor in
                if let error = error {
                    self.errorMessage = "사용자 정보 가져오기 실패: \(error.localizedDescription)"
                    return
                }

                guard let user = user else {
                    self.errorMessage = "사용자 정보가 없습니다"
                    return
                }

                // Supabase에 사용자 정보 저장
                await self.saveUserToSupabase(
                    userId: "\(user.id ?? 0)",
                    provider: .kakao,
                    email: user.kakaoAccount?.email,
                    name: user.kakaoAccount?.profile?.nickname,
                    profileImageUrl: user.kakaoAccount?.profile?.profileImageUrl?.absoluteString
                )
            }
        }
    }

    // MARK: - 애플 로그인

    public func loginWithApple() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.performRequests()
    }

    // MARK: - Supabase에 사용자 저장

    private func saveUserToSupabase(
        userId: String,
        provider: AuthProvider,
        email: String?,
        name: String?,
        profileImageUrl: String?
    ) async {
        // ⚠️ 실제 구현에서는 NetworkKit의 AuthService 사용
        // import NetworkKit 후 아래 코드 활성화

        /*
        do {
            let request = UserUpsertRequest(
                userId: userId,
                provider: provider,
                email: email,
                name: name,
                profileImageUrl: profileImageUrl
            )

            let savedUser = try await AuthService.shared.upsertUser(request)

            print("✅ 사용자 저장 성공: \(savedUser)")

            // 로그인 완료 처리
            self.isLoggedIn = true

            // UserDefaults에 사용자 ID 저장 (다음 실행 시 자동 로그인용)
            UserDefaults.standard.set(savedUser.id.uuidString, forKey: "currentUserId")

        } catch {
            self.errorMessage = "사용자 정보 저장 실패: \(error.localizedDescription)"
        }
        */

        // 임시: 콘솔에 출력
        print("📝 저장할 사용자 정보:")
        print("  - User ID: \(userId)")
        print("  - Provider: \(provider)")
        print("  - Email: \(email ?? "없음")")
        print("  - Name: \(name ?? "없음")")
        print("  - Profile Image: \(profileImageUrl ?? "없음")")

        isLoggedIn = true
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension LoginViewModel: ASAuthorizationControllerDelegate {

    public func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            errorMessage = "Apple 인증 정보를 가져올 수 없습니다"
            return
        }

        let userId = credential.user
        let email = credential.email
        let fullName = credential.fullName

        var name: String?
        if let givenName = fullName?.givenName, let familyName = fullName?.familyName {
            name = "\(familyName)\(givenName)"
        }

        Task {
            await saveUserToSupabase(
                userId: userId,
                provider: .apple,
                email: email,
                name: name,
                profileImageUrl: nil
            )
        }
    }

    public func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        Task { @MainActor in
            self.errorMessage = "Apple 로그인 실패: \(error.localizedDescription)"
        }
    }
}

// MARK: - AuthProvider 임시 정의 (NetworkKit import 후 제거)

public enum AuthProvider: String, Codable {
    case kakao
    case apple
}
