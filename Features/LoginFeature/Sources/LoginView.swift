
import SwiftUI
import LoginFeatureInterface
import DesignSystemKit

public struct LoginView: View {

    @State private var viewModel = LoginViewModel()

    public init() {}
    
    public var body: some View {
        ZStack {
            DesignColor.loginBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                topBar
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                
                centerContent
                    .padding(.horizontal, 24)
                    .padding(.top, 58)
                
                Spacer()
                
                loginButtons
                    .padding(.horizontal, 24)
                
                termsText
                    .padding(.top, 50)
                    .padding(.bottom, 32)
            }
        }
    }
}

private extension LoginView {
    var topBar: some View {
        HStack {
            Button {
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 22, weight: .regular))
                    .foregroundStyle(DesignColor.white)
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(.plain)
            
            Spacer()
        }
    }
    
    var centerContent: some View {
        VStack(spacing: 16) {
            Text("BODY\nFIT")
                .font(.system(size: 72, weight: .heavy))
                .foregroundStyle(DesignColor.slateLight)
                .multilineTextAlignment(.center)
                .lineSpacing(-8)
                .tracking(-1.6)
            
            Text("당신의 한계를 뛰어넘으세요")
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(DesignColor.brandOrange)
        }
        .frame(maxWidth: .infinity)
    }
    
    var loginButtons: some View {
        VStack(spacing: 24) {
            Button {
                viewModel.loginWithKakao()
            } label: {
                HStack(spacing: 16) {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(DesignColor.kakaoText)
                    } else {
                        Image(systemName: "bubble.left")
                            .font(.system(size: 21, weight: .medium))
                    }

                    Text("Kakao로 로그인")
                        .font(.system(size: 18, weight: .bold))
                }
                .foregroundStyle(DesignColor.kakaoText)
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                .background(DesignColor.kakaoYellow)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
            .disabled(viewModel.isLoading)

            Button {
                viewModel.loginWithApple()
            } label: {
                HStack(spacing: 16) {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(DesignColor.white)
                    } else {
                        Image(systemName: "applelogo")
                            .font(.system(size: 18, weight: .semibold))
                    }

                    Text("Apple로 로그인")
                        .font(.system(size: 18, weight: .bold))
                }
                .foregroundStyle(DesignColor.white)
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                .background(DesignColor.black)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(DesignColor.blackButtonBorder, lineWidth: 1)
                }
            }
            .buttonStyle(.plain)
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
    
    var termsText: some View {
        Text("로그인 시 BodyFit의 이용약관 및 개인정보처리방침에 동의합니다.")
            .font(.system(size: 12, weight: .regular))
            .foregroundStyle(DesignColor.slate600)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
    }
}
