//
//  WeatherService.swift
//  running-check
//
//  Created by mason on 11/18/24.
// 

import Foundation
import Combine

class WeatherService {
    private let apiKey = "acf2a01baada6c80f15aeeaed1728d39" // OpenWeather API 키를 여기에 입력하세요.
    private let baseUrl = "https://api.openweathermap.org/data/3.0/onecall"

    func fetchWeather(lat: Double, lon: Double) -> AnyPublisher<OneCallResponse, Error> {
        guard let url = URL(string: "\(baseUrl)?lat=\(lat)&lon=\(lon)&exclude=minutely,alerts&units=metric&appid=\(apiKey)") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: OneCallResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
