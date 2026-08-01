
import SwiftUI
import LoginFeatureInterface
import DesignSystemKit
import CharacterKit

public struct LoginView: View {

    @State private var viewModel = LoginViewModel()

    public init() {}

    public var body: some View {
        ZStack {
            DesignColor.canvas
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer(minLength: 0)

                PushUpCharacterView(
                    phase: 0.7,
                    mood: .resting,
                    palette: DesignColor.brand,
                    scale: 1.2
                )

                titleBlock
                    .padding(.top, DesignSpacing.sm)

                Spacer(minLength: 0)

                loginButtons

                loginStatus

                termsText
                    .padding(.top, DesignSpacing.md)
            }
            .padding(.horizontal, DesignSpacing.screen)
            .padding(.bottom, DesignSpacing.lg)
        }
    }
}

private extension LoginView {

    var titleBlock: some View {
        VStack(spacing: DesignSpacing.sm) {
            Text("BODY FIT")
                .font(.system(size: 44, weight: .black, design: .rounded))
                .foregroundStyle(DesignColor.ink)

            Text("에어팟만 끼면 준비 끝")
                .font(DesignFont.headline)
                .foregroundStyle(DesignColor.brand.deep)
        }
        .multilineTextAlignment(.center)
    }

    var loginButtons: some View {
        VStack(spacing: DesignSpacing.md) {
            Button {
                viewModel.loginWithKakao()
            } label: {
                HStack(spacing: DesignSpacing.sm) {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(DesignColor.kakaoLabel)
                    } else {
                        Image(systemName: "bubble.left.fill")
                    }
                    Text("Kakao로 로그인")
                }
            }
            .buttonStyle(DSButtonStyle(palette: DesignColor.kakao, foreground: DesignColor.kakaoLabel))
            .disabled(viewModel.isLoading)

            Button {
                viewModel.loginWithApple()
            } label: {
                HStack(spacing: DesignSpacing.sm) {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(DesignColor.white)
                    } else {
                        Image(systemName: "applelogo")
                    }
                    Text("Apple로 로그인")
                }
            }
            .buttonStyle(DSButtonStyle(palette: DesignColor.apple))
            .disabled(viewModel.isLoading)
        }
        .alert("오류", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("확인") {
                viewModel.errorMessage = nil
            }
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
    }

    @ViewBuilder
    var loginStatus: some View {
        if viewModel.isLoggedIn {
            VStack(spacing: 2) {
                Text("로그인 성공")
                    .font(DesignFont.label)
                    .foregroundStyle(DesignColor.success.deep)

                if let name = viewModel.loggedInUserName, !name.isEmpty {
                    Text(name)
                        .font(DesignFont.caption)
                        .foregroundStyle(DesignColor.inkMuted)
                }
                if let email = viewModel.loggedInUserEmail, !email.isEmpty {
                    Text(email)
                        .font(DesignFont.caption)
                        .foregroundStyle(DesignColor.inkMuted)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.top, DesignSpacing.md)
        }
    }

    var termsText: some View {
        Text("로그인 시 BodyFit의 이용약관 및 개인정보처리방침에 동의합니다.")
            .font(DesignFont.caption)
            .foregroundStyle(DesignColor.inkMuted)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
    }
}

#Preview {
    LoginView()
}
