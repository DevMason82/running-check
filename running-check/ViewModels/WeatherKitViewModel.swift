//
//  WeatherKitViewModel.swift
//  running-check
//
//  Created by mason on 11/25/24.

import WeatherKit
import Foundation
import CoreLocation

@MainActor
class WeatherKitViewModel: ObservableObject {
    @Published var weatherData: WeatherData?
    @Published var errorMessage: String?
    @Published var runningGrade: RunningGrade?
    @Published var runningCoach: RunningCoach?

    private let weatherService = WeatherService()
    private let locationManager = LocationManagerNew() // 사용자 정의 위치 관리 객체

    init() {
        observeLocationUpdates()
    }

    private func observeLocationUpdates() {
        Task {
            while locationManager.latitude == 0.0 && locationManager.longitude == 0.0 {
                try await Task.sleep(nanoseconds: 500_000_000) // 위치 업데이트 대기
            }
            await fetchWeatherAndEvaluateRunning()
        }
    }

    func fetchWeatherAndEvaluateRunning() async {
        let location = CLLocation(latitude: locationManager.latitude, longitude: locationManager.longitude)

        do {
            let weather = try await weatherService.weather(for: location)
            let currentWeather = weather.currentWeather

            // 적설량은 HourlyForecast에서 첫 번째 데이터를 참조합니다.
            let hourlyForecast = weather.hourlyForecast.first
            let snowfallAmount = hourlyForecast?.precipitationAmount.value ?? 0
            let precipitationChance = hourlyForecast?.precipitationChance ?? 0.0
            let precipitationDescription = getPrecipitationDescription(chance: precipitationChance, amount: snowfallAmount)

            // 최고온도, 최저온도는 DailyForecast에서 가져옵니다.
            let dailyForecast = weather.dailyForecast.first
            let maxTemperature = dailyForecast?.highTemperature.value ?? 0
            let minTemperature = dailyForecast?.lowTemperature.value ?? 0

            // WeatherMetaData 생성
            let metaData = WeatherMetaData(
                date: currentWeather.date,
                expirationDate: currentWeather.metadata.expirationDate,
                location: location
            )

            // WeatherData 생성
            self.weatherData = WeatherData(
                temperature: "\(Int(currentWeather.temperature.value))°C",
                apparentTemperature: "\(Int(currentWeather.apparentTemperature.value))°C",
                conditionDescription: currentWeather.condition.description,
                conditionSymbolName: currentWeather.symbolName,
                conditionMetaData: metaData, // WeatherMetaData 포함
                humidity: "\(Int(currentWeather.humidity * 100))%",
                windSpeed: "\(Int(currentWeather.wind.speed.value)) \(currentWeather.wind.speed.unit.symbol)",
                precipitationProbability: "\(Int(precipitationChance * 100))%",
                maxTemperature: "\(Int(maxTemperature))°C",
                minTemperature: "\(Int(minTemperature))°C",
                uvIndex: "\(currentWeather.uvIndex.value)",
                snowfallAmount: "\(Int(snowfallAmount)) mm (\(precipitationDescription))"
            )

            // 러닝 평가 로직 실행
            let evaluation = RunningEvaluatorNew.evaluate(current: self.weatherData!)
            self.runningGrade = evaluation.grade
            self.runningCoach = evaluation.coach

        } catch {
            self.errorMessage = "Failed to fetch weather data: \(error.localizedDescription)"
        }
    }
    
    // 사용자 업데이트 호출
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
}

//import SwiftUI
//import WeatherKit
//import CoreLocation
//
//@MainActor
//class WeatherKitViewModel: ObservableObject {
//    @Published var weatherData: WeatherData?
//    @Published var errorMessage: String?
//    @Published var runningGrade: RunningGrade?
//    @Published var runningCoach: RunningCoach?
//
//    private let weatherService: WeatherService
//    private let locationManager: LocationManagerNew
//
//    init(weatherService: WeatherService = WeatherService(),
//         locationManager: LocationManagerNew = LocationManagerNew()) {
//        self.weatherService = weatherService
//        self.locationManager = locationManager
//        observeLocationUpdates()
//    }
//
//    /// 위치 업데이트 관찰 및 날씨 데이터 로드
//    private func observeLocationUpdates() {
//        Task {
//            do {
//                let location = try await fetchUserLocation()
//                await fetchWeatherAndEvaluateRunning(location: location)
//            } catch {
//                self.errorMessage = translateError(error)
//                print("Location update failed: \(error.localizedDescription)")
//            }
//        }
//    }
//    
//    /// 사용자 위치 기반으로 날씨 데이터를 가져오고 평가
//       func fetchAndEvaluateWeather() async {
//           do {
//               let location = try await fetchUserLocation()
//               await fetchWeatherAndEvaluateRunning(location: location)
//           } catch {
//               self.errorMessage = translateError(error)
//           }
//       }
//
//    /// 위치 가져오기
//    func fetchUserLocation() async throws -> CLLocation {
//        while locationManager.latitude == 0.0 && locationManager.longitude == 0.0 {
//            try await Task.sleep(nanoseconds: 500_000_000)
//        }
//        return CLLocation(latitude: locationManager.latitude, longitude: locationManager.longitude)
//    }
//
//    /// 날씨 데이터 가져오기 및 러닝 평가
//    func fetchWeatherAndEvaluateRunning(location: CLLocation) async {
//        do {
//            let weatherData = try await fetchWeatherData(location: location)
//            print("Weather data fetched successfully: \(weatherData)")
//            evaluateRunningGrade(weatherData: weatherData)
//        } catch {
//            self.errorMessage = translateError(error)
//            print("Failed to fetch weather data: \(error.localizedDescription)")
//        }
//    }
//
//    /// 날씨 데이터 가져오기
//    private func fetchWeatherData(location: CLLocation) async throws -> WeatherData {
//        let weather = try await weatherService.weather(for: location)
//        let currentWeather = weather.currentWeather
//        
//                    let metaData = WeatherMetaData(
//                        date: currentWeather.date,
//                        expirationDate: currentWeather.metadata.expirationDate,
//                        location: location
//                    )
//
//        // 날씨 데이터 변환
//        return WeatherData(
//            temperature: "\(Int(currentWeather.temperature.value))°C",
//            apparentTemperature: "\(Int(currentWeather.apparentTemperature.value))°C",
//            conditionDescription: currentWeather.condition.description,
//            conditionSymbolName: currentWeather.symbolName,
//            conditionMetaData: metaData,
//            humidity: "\(Int(currentWeather.humidity * 100))%",
//            windSpeed: "\(Int(currentWeather.wind.speed.value)) \(currentWeather.wind.speed.unit.symbol)",
//            precipitationProbability: "N/A",
//            maxTemperature: "N/A",
//            minTemperature: "N/A",
//            uvIndex: "\(currentWeather.uvIndex.value)",
//            snowfallAmount: "N/A"
//        )
//    }
//
//    /// 러닝 평가
//    private func evaluateRunningGrade(weatherData: WeatherData) {
//        let evaluation = RunningEvaluatorNew.evaluate(current: weatherData)
//        self.runningGrade = evaluation.grade
//        self.runningCoach = evaluation.coach
//    }
//    
//    enum WeatherError: Error {
//        case noPermission
//        case networkIssue
//        case unknown
//    }
//
//    /// 에러 메시지 변환
//    func translateError(_ error: Error) -> String {
//        if let weatherError = error as? WeatherError {
//            switch weatherError {
//            case .noPermission:
//                return "날씨 데이터를 가져올 권한이 없습니다. 설정에서 권한을 확인하세요."
//            case .networkIssue:
//                return "네트워크 연결 문제로 데이터를 가져올 수 없습니다."
//            default:
//                return "알 수 없는 오류가 발생했습니다."
//            }
//        }
//        return "오류: \(error.localizedDescription)"
//    }
//}
