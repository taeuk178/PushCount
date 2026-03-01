
import Foundation
import Supabase

public enum SupabaseKeyValue {
    private static let supabaseURL = URL(string: "https://msjbluntfzyaqdklyzdd.supabase.co")!
    private static let supabaseKey = "sb_publishable_e6fo0J1PHB1S8RH83n2xjw_kpKzNrNG"
    
    public static let client = SupabaseClient(
        supabaseURL: SupabaseKeyValue.supabaseURL,
        supabaseKey: SupabaseKeyValue.supabaseKey
    )
}
