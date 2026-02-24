# Supabase + 소셜 로그인 설정 가이드

## 1. Supabase 테이블 생성

Supabase 대시보드에서 SQL Editor를 열고 다음 쿼리를 실행하세요:

```sql
-- users 테이블 생성
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id TEXT UNIQUE NOT NULL,
    provider TEXT NOT NULL,
    email TEXT,
    name TEXT,
    profile_image_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_login_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 인덱스 생성
CREATE INDEX idx_users_user_id ON users(user_id);
CREATE INDEX idx_users_provider ON users(provider);

-- 운동 기록 테이블
CREATE TABLE workout_records (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    exercise_type TEXT NOT NULL,
    count INTEGER NOT NULL,
    duration_seconds INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 주간 목표 테이블
CREATE TABLE weekly_goals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    week_start_date DATE NOT NULL,
    goal_days INTEGER DEFAULT 5,
    completed_days INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, week_start_date)
);
```

## 2. Supabase 환경 변수 설정

`Modules/NetworkKit/Sources/SupabaseClient.swift` 파일을 열고 다음을 수정하세요:

```swift
let supabaseURL = URL(string: "https://YOUR_PROJECT_ID.supabase.co")!
let supabaseKey = "YOUR_ANON_PUBLIC_KEY"
```

Supabase 대시보드 → Settings → API에서 확인:
- `URL`: Project URL
- `anon/public key`: anon public key

## 3. 카카오 SDK 설정

### 3.1. 카카오 개발자 콘솔 설정
1. https://developers.kakao.com 접속
2. 애플리케이션 생성
3. 네이티브 앱 키 복사

### 3.2. Info.plist 설정

`App/Resources/Info.plist` 생성:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>KAKAO_APP_KEY</key>
    <string>YOUR_KAKAO_NATIVE_APP_KEY</string>
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeRole</key>
            <string>Editor</string>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>kakaoYOUR_KAKAO_NATIVE_APP_KEY</string>
            </array>
        </dict>
    </array>
    <key>LSApplicationQueriesSchemes</key>
    <array>
        <string>kakaokompassauth</string>
        <string>kakaolink</string>
        <string>kakaoplus</string>
    </array>
</dict>
</plist>
```

### 3.3. AppDelegate 또는 App에 카카오 초기화

`App/Sources/PushCountApp.swift` 수정:

```swift
import SwiftUI
import KakaoSDKCommon
import KakaoSDKAuth

@main
struct PushCountApp: App {

    init() {
        // 카카오 SDK 초기화
        let kakaoAppKey = Bundle.main.object(forInfoDictionaryKey: "KAKAO_APP_KEY") as? String ?? ""
        KakaoSDK.initSDK(appKey: kakaoAppKey)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    if AuthApi.isKakaoTalkLoginUrl(url) {
                        _ = AuthController.handleOpenUrl(url: url)
                    }
                }
        }
    }
}
```

## 4. 프로젝트 빌드

```bash
# 1. 의존성 설치
cd /Users/taeuk/Desktop/Dev/PushCount
tuist install

# 2. 프로젝트 생성
tuist generate

# 3. Xcode에서 열기
open PushCount.xcworkspace
```

## 5. 사용 방법

### LoginView에서 로그인

```swift
import SwiftUI
import LoginFeature

struct ContentView: View {
    var body: some View {
        LoginView()
    }
}
```

### 로그인 후 사용자 정보 가져오기

```swift
import NetworkKit

// 현재 로그인한 사용자 ID
if let userIdString = UserDefaults.standard.string(forKey: "currentUserId"),
   let userId = UUID(uuidString: userIdString) {
    Task {
        do {
            let user = try await AuthService.shared.getUser(byId: userId)
            print("현재 사용자: \(user?.name ?? "Unknown")")
        } catch {
            print("사용자 정보 가져오기 실패: \(error)")
        }
    }
}
```

### 운동 기록 저장

```swift
// WorkoutRecord 모델 추가 (NetworkKit/Sources/)
public struct WorkoutRecord: Codable {
    public let userId: UUID
    public let exerciseType: String
    public let count: Int
    public let durationSeconds: Int?

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case exerciseType = "exercise_type"
        case count
        case durationSeconds = "duration_seconds"
    }
}

// 운동 기록 저장
let record = WorkoutRecord(
    userId: currentUserId,
    exerciseType: "PUSH_UPS",
    count: 50,
    durationSeconds: 300
)

try await SupabaseClient.shared.client
    .from("workout_records")
    .insert(record)
    .execute()
```

## 6. 테스트 순서

1. ✅ Tuist 의존성 설치 완료
2. ✅ Supabase URL/Key 설정
3. ✅ 카카오 앱 키 설정
4. ✅ 프로젝트 생성 후 빌드
5. ✅ LoginView에서 카카오/애플 로그인 테스트
6. ✅ Supabase 대시보드에서 users 테이블 확인
7. ✅ 운동 기록 저장 테스트

## 7. 데이터 구조 예시

### users 테이블
| id (UUID) | user_id | provider | email | name | created_at |
|-----------|---------|----------|-------|------|------------|
| uuid-1    | 123456789 | kakao  | user@email.com | 홍길동 | 2024-01-01 |
| uuid-2    | 001234.abc | apple | user2@icloud.com | 김철수 | 2024-01-02 |

### workout_records 테이블
| id | user_id | exercise_type | count | duration_seconds | created_at |
|----|---------|---------------|-------|------------------|------------|
| 1  | uuid-1  | PUSH_UPS     | 50    | 300              | 2024-01-01 |
| 2  | uuid-1  | PULL_UPS     | 10    | 120              | 2024-01-01 |

## 8. 주의사항

⚠️ **보안**
- Supabase Key는 절대 Git에 커밋하지 마세요
- `.gitignore`에 환경 변수 파일 추가
- RLS (Row Level Security) 정책 설정 권장

⚠️ **카카오 로그인**
- 앱 심사 전 카카오 개발자 콘솔에서 앱 승인 필요
- 비즈 앱 전환 필요 (무료)

⚠️ **애플 로그인**
- Apple Developer Program 가입 필요
- Sign in with Apple capability 활성화
