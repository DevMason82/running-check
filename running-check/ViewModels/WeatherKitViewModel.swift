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

@MainActor
class WeatherKitViewModel: ObservableObject {
    @Published var weatherData: WeatherData?
    @Published var errorMessage: String?
    @Published var runningGrade: RunningGrade?
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
    
    // 동기 메서드 추가
    private func updateWeatherDataSync() {
        updateWeatherData()
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
            print(self.weatherData!)

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
