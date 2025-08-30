import Foundation

public struct PushCountModel: Codable, Identifiable, Equatable {
    public let id: UUID
    public let count: Int
    public let date: Date
    public let exercise: String
    
    public init(
        id: UUID = UUID(),
        count: Int,
        date: Date = Date(),
        exercise: String
    ) {
        self.id = id
        self.count = count
        self.date = date
        self.exercise = exercise
    }
}

public extension PushCountModel {
    static let sample = PushCountModel(
        count: 50,
        exercise: "Push-up"
    )
    
    static let samples = [
        PushCountModel(count: 30, exercise: "Push-up"),
        PushCountModel(count: 45, exercise: "Push-up"),
        PushCountModel(count: 60, exercise: "Push-up")
    ]
}