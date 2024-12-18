//
//  WeatherKitViewModel.swift
//  running-check
//
//  Created by mason on 11/25/24.

import Foundation
import WeatherKit
import CoreLocation
import Combine
import UIKit

// 러닝 등급
enum RunningGrade: String {
    case good = "Good"
    case warning = "Warning"
    case danger = "Danger"
}

// 러닝 코치 메세지
struct RunningCoach {
    let comment: String
    let alternative: String
    let gear: String
    let shoes: String
}

@MainActor
class WeatherKitViewModel: ObservableObject {
    @Published var weatherData: WeatherData?
    @Published var errorMessage: String?
    @Published var runningGrade: RunningGrade? // 초기값은 nil
    @Published var runningCoach: RunningCoach?
    
    private let weatherService = WeatherService()
    private let locationManager = LocationManagerNew()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        observeLocationUpdates()
        observeAppLifecycle() // 앱 상태 변화 감지
    }
    
    private func observeLocationUpdates() {
        Task {
            while locationManager.latitude == 0.0 && locationManager.longitude == 0.0 {
                try await Task.sleep(nanoseconds: 500_000_000) // 위치 업데이트 대기
            }
            await fetchWeatherAndEvaluateRunning()
        }
    }
    
    private func observeAppLifecycle() {
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { [weak self] _ in
                print("App entered foreground")
                Task {
                    self?.updateWeatherData() // 비동기 호출
                }
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
            .sink { _ in
                print("App entered background")
                // 필요시 백그라운드 상태 전환 로직 추가
            }
            .store(in: &cancellables)
    }
    
    /// 네트워크 요청과 재시도 로직을 포함한 함수
    func fetchWeatherAndEvaluateRunning() async {
        let location = CLLocation(latitude: locationManager.latitude, longitude: locationManager.longitude)
        let maxRetries = 3
        var attempt = 0
        
        while attempt < maxRetries {
            attempt += 1
            do {
                // 네트워크 요청에 Timeout 설정 적용
                let weather = try await withTimeout(seconds: 10) { [self] in
                    try await self.weatherService.weather(for: location)
                }
                let currentWeather = weather.currentWeather
                
                // WeatherData 생성
                let hourlyForecast = weather.hourlyForecast.first
                let snowfallAmount = hourlyForecast?.precipitationAmount.value ?? 0
                let precipitationChance = hourlyForecast?.precipitationChance ?? 0.0
                let precipitationDescription = getPrecipitationDescription(chance: precipitationChance, amount: snowfallAmount)
                
                let dailyForecast = weather.dailyForecast.first
                let maxTemperature = dailyForecast?.highTemperature.value ?? 0
                let minTemperature = dailyForecast?.lowTemperature.value ?? 0
                
                let metaData = WeatherMetaData(
                    date: currentWeather.date,
                    expirationDate: currentWeather.metadata.expirationDate,
                    location: location
                )
                
                self.weatherData = WeatherData(
                    temperature: "\(Int(currentWeather.temperature.value))°C",
                    apparentTemperature: "\(Int(currentWeather.apparentTemperature.value))°C",
                    conditionDescription: currentWeather.condition.description,
                    conditionSymbolName: currentWeather.symbolName,
                    conditionMetaData: metaData,
                    humidity: "\(Int(currentWeather.humidity * 100))%",
                    windSpeed: "\(Int(currentWeather.wind.speed.value)) \(currentWeather.wind.speed.unit.symbol)",
                    precipitationProbability: "\(Int(precipitationChance * 100))%",
                    maxTemperature: "\(Int(maxTemperature))°C",
                    minTemperature: "\(Int(minTemperature))°C",
                    uvIndex: "\(currentWeather.uvIndex.value)",
                    snowfallAmount: "\(Int(snowfallAmount)) mm (\(precipitationDescription))"
                )
                print(self.weatherData!)
                
                // 러닝 평가 로직 실행
                let evaluation = RunningEvaluatorNew.evaluate(current: self.weatherData!)
                self.runningGrade = evaluation.grade
                self.runningCoach = evaluation.coach
                return
            } catch {
                print("Attempt \(attempt): \(error.localizedDescription)")
                if attempt >= maxRetries {
                    self.errorMessage = "네트워크 요청이 실패했습니다. 인터넷 상태를 확인해주세요."
                }
            }
        }
    }
    
    func updateWeatherData() {
        Task {
            await fetchWeatherAndEvaluateRunning()
        }
    }
    
    private func getPrecipitationDescription(chance: Double, amount: Double) -> String {
        if chance > 0.8 && amount > 2.0 {
            return "강함"
        } else if chance > 0.5 {
            return "약함"
        } else {
            return "없음"
        }
    }
    
    /// 타임아웃 설정을 추가한 Helper 함수
    private func withTimeout<T>(seconds: Double, operation: @escaping () async throws -> T) async throws -> T {
        // Task.sleep의 최대 단위는 나노초이므로 초 단위를 변환합니다.
        let timeoutNanoseconds = UInt64(seconds * 1_000_000_000)
        
        // Task 그룹을 사용하여 타임아웃과 실제 작업을 동시에 실행
        return try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                try await operation() // 실제 작업 수행
            }
            
            group.addTask {
                try await Task.sleep(nanoseconds: timeoutNanoseconds) // 타임아웃 설정
                throw URLError(.timedOut, userInfo: [NSLocalizedDescriptionKey: "The request timed out"])
            }
            
            guard let result = try await group.next() else {
                throw URLError(.unknown, userInfo: [NSLocalizedDescriptionKey: "Unknown error occurred"])
            }
            group.cancelAll() // 다른 작업을 취소
            return result
        }
    }
}
