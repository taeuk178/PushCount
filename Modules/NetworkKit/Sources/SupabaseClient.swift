import Foundation
import Supabase

public final class SupabaseClient {
    public static let shared = SupabaseClient()

    public let client: SupabaseSwift.Client

    private init() {
        // ⚠️ 실제 프로젝트에서는 환경 변수나 Config 파일에서 가져오세요
        let supabaseURL = URL(string: "YOUR_SUPABASE_URL")!
        let supabaseKey = "YOUR_SUPABASE_ANON_KEY"

        client = SupabaseSwift.Client(
            supabaseURL: supabaseURL,
            supabaseKey: supabaseKey
        )
    }
}
