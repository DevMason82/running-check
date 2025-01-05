//
//  WeeklyRunningDataViewModel.swift
//  running-check
//
//  Created by mason on 1/1/25.
//

import Foundation
import HealthKit

struct RunningDayStatus: Identifiable {
    let id = UUID()
    let day: String
    let hasRun: Bool
}

struct RunningDayData: Identifiable, Hashable {
    let id: UUID = UUID()
    let date: Date
    let distance: Double
    let duration: TimeInterval
    let calories: Double
    let heartRate: Double
    let pace: Double
    let cadence: Double
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: RunningDayData, rhs: RunningDayData) -> Bool {
        return lhs.id == rhs.id
    }
}

class WeeklyRunningDataViewModel: ObservableObject {
    private let healthKitManager = WeeklyRunningDataManager()
    @Published var weeklyRunningStatus: [RunningDayStatus] = []
    @Published var selectedDayDetails: [RunningDayData] = []
    @Published var isLoading = false
    @Published var showDetails = false
    
    init() {
        Task { [weak self] in
            await self?.fetchWeeklyRunningData()
        }
    }
    
    // 주간 러닝 데이터 가져오기 (async/await 버전)
    func fetchWeeklyRunningData() async {
        await MainActor.run {
            self.isLoading = true
        }
        
        do {
            let workouts = try await healthKitManager.fetchWeeklyRunningData()
            await MainActor.run {
                self.isLoading = false
                self.weeklyRunningStatus = self.processRunningData(workouts)
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.weeklyRunningStatus = self.generateEmptyWeek()
            }
        }
    }

    
    // 특정 요일 선택 시 세부 정보 가져오기 (async/await)
    func fetchRunningDetails(for day: String) async {
        await MainActor.run {
            self.isLoading = true
        }
        
        do {
            let workouts = try await healthKitManager.fetchWeeklyRunningData()
            var details: [RunningDayData] = []
            
            await withTaskGroup(of: RunningDayData?.self) { group in
                for workout in workouts {
                    group.addTask {
                        let workoutDay = self.convertWeekdayToKorean(Calendar.current.component(.weekday, from: workout.startDate))
                        if workoutDay == day {
                            return await self.extractWorkoutData(for: workout)
                        }
                        return nil
                    }
                }
                
                for await result in group {
                    if let detail = result {
                        details.append(detail)
                    }
                }
            }
            
            await MainActor.run {
                self.selectedDayDetails = details
                self.showDetails = true
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
            }
            print("Error fetching running details: \(error.localizedDescription)")
        }
    }
    
    // 개별 워크아웃에서 데이터 추출 (비동기)
    private func extractWorkoutData(for workout: HKWorkout) async -> RunningDayData {
        let activeEnergyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let speedType = HKQuantityType.quantityType(forIdentifier: .runningSpeed)!
        
        let totalCalories = workout.statistics(for: activeEnergyType)?.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0
        let totalDistance = workout.statistics(for: distanceType)?.sumQuantity()?.doubleValue(for: .meter()) ?? 0
        let averageHeartRate = workout.statistics(for: heartRateType)?.averageQuantity()?.doubleValue(for: HKUnit(from: "count/min")) ?? 0
        let averageSpeed = workout.statistics(for: speedType)?.averageQuantity()?.doubleValue(for: HKUnit.meter().unitDivided(by: HKUnit.second())) ?? 0
        let totalSteps = workout.statistics(for: stepCountType)?.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
        
        let pacePerKm = averageSpeed > 0 ? 1000 / averageSpeed : 0
        let averageCadence = workout.duration > 0 ? (totalSteps / workout.duration) * 60 : 0
        
        return RunningDayData(
            date: workout.startDate,
            distance: totalDistance,
            duration: workout.duration,
            calories: totalCalories,
            heartRate: averageHeartRate,
            pace: pacePerKm,
            cadence: averageCadence
        )
    }
    
    // 주간 러닝 상태 처리 (요일별)
    private func processRunningData(_ workouts: [HKWorkout]) -> [RunningDayStatus] {
        let calendar = Calendar.current
        var dayStatus: [String: Bool] = generateEmptyWeekDict()
        
        for workout in workouts {
            let day = calendar.component(.weekday, from: workout.startDate)
            let dayName = convertWeekdayToKorean(day)
            dayStatus[dayName] = true
        }
        
        return dayStatus
            .map { RunningDayStatus(day: $0.key, hasRun: $0.value) }
            .sorted(by: { weekdayOrder($0.day) < weekdayOrder($1.day) })
    }

    // 요일 변환 (숫자 → 한국어 요일)
    private func convertWeekdayToKorean(_ weekday: Int) -> String {
        let weekdays = ["일", "월", "화", "수", "목", "금", "토"]
        return weekdays[weekday - 1]
    }

    // 요일 정렬 (일요일부터 시작)
    private func weekdayOrder(_ day: String) -> Int {
        let weekdays = ["일", "월", "화", "수", "목", "금", "토"]
        return weekdays.firstIndex(of: day.prefix(1).description) ?? 7
    }

    // 주간 초기 상태 (일요일부터 시작)
    private func generateEmptyWeek() -> [RunningDayStatus] {
        let weekdays = ["일", "월", "화", "수", "목", "금", "토"]
        return weekdays.map { RunningDayStatus(day: $0, hasRun: false) }
    }

    // 주간 초기 상태 딕셔너리 (일요일부터 시작)
    private func generateEmptyWeekDict() -> [String: Bool] {
        let weekdays = ["일", "월", "화", "수", "목", "금", "토"]
        return weekdays.reduce(into: [:]) { $0[$1] = false }
    }
}
