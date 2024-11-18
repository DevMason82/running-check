//
//  WeatherModel.swift
//  running-check
//
//  Created by mason on 11/18/24.
//

import Foundation

struct OneCallResponse: Codable {
    let current: CurrentWeather
    let hourly: [HourlyWeather]
    let daily: [DailyWeather]
}

struct CurrentWeather: Codable {
    let temp: Double
    let feels_like: Double
    let humidity: Int
    let weather: [Weather]
}

struct HourlyWeather: Codable {
    let dt: Int
    let temp: Double
    let weather: [Weather]
}

struct DailyWeather: Codable {
    let dt: Int
    let temp: Temp
    let weather: [Weather]
}

struct Temp: Codable {
    let day: Double
    let night: Double
}

struct Weather: Codable {
    let description: String
    let icon: String
}
