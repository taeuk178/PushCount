
import Foundation
import KakaoSDKUser
import KakaoSDKAuth
import NetworkKit

@MainActor
@Observable
public final class LoginViewModel {

    public var isLoading = false
    public var errorMessage: String?
    public var isLoggedIn = false
    public var loggedInUserName: String?
    public var loggedInUserEmail: String?

    public init() {}

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
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let appleUser = try await AuthService.shared.appleSignIn.signIn()

                isLoading = false
                isLoggedIn = true
                loggedInUserName = appleUser.name
                loggedInUserEmail = appleUser.email

                print("✅ Apple 로그인 성공")
                print("  - userId: \(appleUser.userId)")
                print("  - email: \(appleUser.email ?? "없음")")
                print("  - name: \(appleUser.name ?? "없음")")
            } catch {
                isLoading = false
                errorMessage = "Apple 로그인 실패: \(error.localizedDescription)"
            }
        }
    }

    // MARK: - Supabase에 사용자 저장

    private func saveUserToSupabase(
        userId: String,
        provider: AuthProvider,
        email: String?,
        name: String?,
        profileImageUrl: String?
    ) async {
        // Supabase 저장은 현재 비활성화, 로그인 동작 확인용 처리
        print("📝 저장할 사용자 정보:")
        print("  - User ID: \(userId)")
        print("  - Provider: \(provider)")
        print("  - Email: \(email ?? "없음")")
        print("  - Name: \(name ?? "없음")")
        print("  - Profile Image: \(profileImageUrl ?? "없음")")

        loggedInUserName = name
        loggedInUserEmail = email
        isLoggedIn = true
    }
}
