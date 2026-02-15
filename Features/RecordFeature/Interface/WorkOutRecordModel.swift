//
//  WorkOutRecord.swift
//  RecordFeatureInterface
//
//  Created by taeuk on 2/15/26.
//

import Foundation

public struct WorkoutRecord: Identifiable {
    public let id = UUID()
    public let date: String
    public let title: String
    public let reps: Int
    public let duration: String
    public let calories: Int
    
    public init(date: String, title: String, reps: Int, duration: String, calories: Int) {
        self.date = date
        self.title = title
        self.reps = reps
        self.duration = duration
        self.calories = calories
    }
}
