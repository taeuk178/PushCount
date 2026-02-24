
import SwiftUI
import LoginFeatureInterface

public struct LoginView: View {

    @State private var viewModel = LoginViewModel()

    public init() {}
    
    public var body: some View {
        ZStack {
            Color(red: 0.0, green: 0.19, blue: 0.29)
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
                    .foregroundStyle(Color.white)
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
                .foregroundStyle(Color(red: 0.95, green: 0.96, blue: 0.98))
                .multilineTextAlignment(.center)
                .lineSpacing(-8)
                .tracking(-1.6)
            
            Text("당신의 한계를 뛰어넘으세요")
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(Color(red: 0.97, green: 0.50, blue: 0.0))
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
                            .tint(Color(red: 0.06, green: 0.09, blue: 0.16))
                    } else {
                        Image(systemName: "bubble.left")
                            .font(.system(size: 21, weight: .medium))
                    }

                    Text("Kakao로 로그인")
                        .font(.system(size: 18, weight: .bold))
                }
                .foregroundStyle(Color(red: 0.06, green: 0.09, blue: 0.16))
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                .background(Color(red: 0.996, green: 0.898, blue: 0.0))
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
                            .tint(Color.white)
                    } else {
                        Image(systemName: "applelogo")
                            .font(.system(size: 18, weight: .semibold))
                    }

                    Text("Apple로 로그인")
                        .font(.system(size: 18, weight: .bold))
                }
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                .background(Color.black)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(red: 0.15, green: 0.15, blue: 0.17), lineWidth: 1)
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
            .foregroundStyle(Color(red: 0.40, green: 0.46, blue: 0.55))
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
    }
}
