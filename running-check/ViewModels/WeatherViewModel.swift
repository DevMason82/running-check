//
//  WeatherViewModel.swift
//  running-check
//
//  Created by mason on 11/18/24.
//

import Foundation
import Combine

class WeatherViewModel: ObservableObject {
    @Published var latitude: String = "37.52" // 기본값
    @Published var longitude: String = "126.97" // 기본값
    @Published var currentTemp: String = ""
    @Published var weatherDescription: String = ""
    @Published var dailyForecast: [String] = []
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()
    private let weatherService = WeatherService()

    func fetchWeather() {
        // String 값을 Double로 변환
        guard let lat = Double(latitude), let lon = Double(longitude) else {
            errorMessage = "유효한 위도와 경도를 입력하세요."
            return
        }

        weatherService.fetchWeather(lat: lat, lon: lon)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    self.errorMessage = "날씨 데이터를 가져오는데 실패했습니다: \(error.localizedDescription)"
                case .finished:
                    break
                }
            }, receiveValue: { response in
                self.currentTemp = "\(response.current.temp)°C"
                self.weatherDescription = response.current.weather.first?.description ?? "No description"
                self.dailyForecast = response.daily.map { day in
                    let date = Date(timeIntervalSince1970: TimeInterval(day.dt))
                    let formatter = DateFormatter()
                    formatter.dateStyle = .short
                    return "\(formatter.string(from: date)): \(day.temp.day)°C (Day)"
                }
                self.errorMessage = nil
            })
            .store(in: &cancellables)
    }
}
