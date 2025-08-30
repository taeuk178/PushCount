import Foundation

public struct UserSettings: Codable {
    public var dailyGoal: Int
    public var notificationsEnabled: Bool
    public var preferredExercises: [String]
    public var theme: Theme
    
    public enum Theme: String, CaseIterable, Codable {
        case light = "light"
        case dark = "dark"
        case system = "system"
        
        public var displayName: String {
            switch self {
            case .light: return "Light"
            case .dark: return "Dark"  
            case .system: return "System"
            }
        }
    }
    
    public init(
        dailyGoal: Int = 50,
        notificationsEnabled: Bool = true,
        preferredExercises: [String] = ["Push-up"],
        theme: Theme = .system
    ) {
        self.dailyGoal = dailyGoal
        self.notificationsEnabled = notificationsEnabled
        self.preferredExercises = preferredExercises
        self.theme = theme
    }
    
    public static let `default` = UserSettings()
}