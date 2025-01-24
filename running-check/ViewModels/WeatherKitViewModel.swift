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
struct RunningCoach: Hashable {
    let id: UUID = UUID()
    let simpleFeedback: String
    let comment: String
    let alternative: String
    let gear: String
    let shoes: String
}

enum Season {
    case spring, summer, autumn, winter
}

@MainActor
class WeatherKitViewModel: ObservableObject {
    @Published var weatherData: WeatherData?
        @Published var errorMessage: String?
        @Published var runningGrade: RunningGrade? // 초기값은 nil
        @Published var runningCoach: RunningCoach?
        @Published var airQualityIndex: Int? // 대기질 지수 (AQI)
        @Published var airQualityCategory: String? // 대기질 카테고리
        @Published var pollutants: [String: Double] = [:] // 대기 오염 물질
        
        private let weatherService = WeatherService()
        private let airQualityService = AirQualityService()
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
        
        private func determineSeason() -> Season {
            let currentMonth = Calendar.current.component(.month, from: Date())
            
            switch currentMonth {
            case 3...5:
                return .spring
            case 6...8:
                return .summer
            case 9...11:
                return .autumn
            default:
                return .winter
            }
        }
    
    private func seasonDescription(for season: Season) -> String {
            switch season {
            case .spring:
                return "봄 (Spring)"
            case .summer:
                return "여름 (Summer)"
            case .autumn:
                return "가을 (Autumn)"
            case .winter:
                return "겨울 (Winter)"
            }
        }
        
        func fetchWeatherAndEvaluateRunning() async {
            let location = CLLocation(latitude: locationManager.latitude, longitude: locationManager.longitude)
            let maxRetries = 3
            var attempt = 0
            
            while attempt < maxRetries {
                attempt += 1
                do {
                    // 날씨 데이터 가져오기
                    let weather = try await withTimeout(seconds: 10) { [self] in
                        try await self.weatherService.weather(for: location)
                    }
                    let currentWeather = weather.currentWeather
                    
                    // 대기질 데이터 가져오기
                    let airPollutionResponse = try await airQualityService.fetchAirPollution(for: location)
                    let airQualityData = airPollutionResponse.list.first
                    let airQualityIndex = airQualityData?.main.aqi ?? 0
                    let airQualityComponents = airQualityData?.components ?? AirPollutionResponse.ListItem.Components()
                    
                    self.airQualityIndex = airQualityIndex
                    self.airQualityCategory = airQualityCategory(for: airQualityIndex)
                    self.pollutants = [
                        "CO": airQualityComponents.co,
                        "NO": airQualityComponents.no,
                        "NO₂": airQualityComponents.no2,
                        "O₃": airQualityComponents.o3,
                        "SO₂": airQualityComponents.so2,
                        "PM2.5": airQualityComponents.pm2_5,
                        "PM10": airQualityComponents.pm10,
                        "NH₃": airQualityComponents.nh3
                    ]
                    
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
                    
                    let season = determineSeason()
                    
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
                        snowfallAmount: "\(Int(snowfallAmount)) mm (\(precipitationDescription))",
                        airQualityIndex: "\(airQualityIndex)",
                        airQualityCategory: airQualityCategory ?? "알 수 없음",
                        season: seasonDescription(for: season),
                        pollutants: self.pollutants
                    )
                    
                    print(self.weatherData!)
                    
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

        private func airQualityCategory(for index: Int) -> String {
            switch index {
            case 1: return "좋음"
            case 2: return "보통"
            case 3: return "나쁨"
            case 4: return "매우 나쁨"
            case 5: return "위험"
            default: return "알 수 없음"
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
