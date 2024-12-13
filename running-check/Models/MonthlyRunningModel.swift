//
//  MonthlyRunningModel.swift
//  running-check
//
//  Created by mason on 12/12/24.
//

import Foundation

struct MonthlyRunningModel {
    let totalRunningDistance: Double
    let totalCaloriesBurned: Double
    let totalRunningTime: TimeInterval
    let averagePace: TimeInterval
    let averageCadence: Double
    let indoorRunCount: Int
    let outdoorRunCount: Int
    let currentMonth: String
}

// 런 데이터 구조체
struct RunData {
    let date: Date
    let duration: TimeInterval
    let distance: Double
    let calories: Double
    let pace: Double
    let cadence: Double
    
}
