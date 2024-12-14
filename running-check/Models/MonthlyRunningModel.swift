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

struct RunningReport {
    let totalDistance: Double // 총 거리 (km)
    let totalCalories: Double // 총 소모 칼로리 (kcal)
    let totalDuration: TimeInterval // 총 러닝 시간 (초)
    let averagePace: Double // 평균 페이스 (초/킬로미터)
    let averageCadence: Double // 평균 케이던스 (spm)
    let runCount: Int // 러닝 횟수
}
