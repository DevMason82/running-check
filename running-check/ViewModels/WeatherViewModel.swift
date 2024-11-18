//
//  WeatherViewModel.swift
//  running-check
//
//  Created by mason on 11/18/24.
//

import Foundation
import Combine

class WeatherViewModel: ObservableObject {
    @Published var latitude: String = ""
    @Published var longitude: String = ""
    @Published var currentTemp: String = ""
    @Published var weatherDescription: String = ""
    @Published var dailyForecast: [String] = []
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()
    private let weatherService = WeatherService()

    func fetchWeather() {
        guard let lat = Double(latitude), let lon = Double(longitude) else {
            errorMessage = "Invalid latitude or longitude"
            return
        }

        weatherService.fetchWeather(lat: lat, lon: lon)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    self.errorMessage = "Failed to fetch weather: \(error.localizedDescription)"
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
