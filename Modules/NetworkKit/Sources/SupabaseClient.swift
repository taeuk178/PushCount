
import Foundation
import Supabase

public enum SupabaseKeyValue {
    private static let supabaseURL = URL(string: "YOUR_SUPABASE_URL")!
    private static let supabaseKey = "YOUR_SUPABASE_ANON_KEY"
    
    public static let client = SupabaseClient(
        supabaseURL: SupabaseKeyValue.supabaseURL,
        supabaseKey: SupabaseKeyValue.supabaseKey
    )
}

//public final class SupabaseInfo {
//    
//    public static let client = SupabaseClient(
//        supabaseURL: SupabaseKeyValue.supabaseURL,
//        supabaseKey: SupabaseKeyValue.supabaseKey
//    )
//    
//    public static let shared = SupabaseInfo()
//    
//    private init() { }
//    
//}
