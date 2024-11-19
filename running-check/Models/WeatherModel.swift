//
//  WeatherModel.swift
//  running-check
//
//  Created by mason on 11/18/24.
//

import Foundation

// 전체 응답 모델
struct OneCallResponse: Codable {
    let current: CurrentWeather
    let hourly: [HourlyWeather]
    let daily: [DailyWeather]
}

// 현재 날씨 모델
struct CurrentWeather: Codable {
    let dt: Int
    let sunrise: Int
    let sunset: Int
    let temp: Double
    let feels_like: Double
    let pressure: Int
    let humidity: Int
    let dew_point: Double
    let uvi: Double
    let clouds: Int
    let visibility: Int
    let wind_speed: Double
    let wind_deg: Int
    let wind_gust: Double?
    let weather: [Weather]
    let rain: Rain? // 비 데이터
    let snow: Snow? // 눈 데이터
}

// 시간별 날씨 모델
struct HourlyWeather: Codable {
    let dt: Int
    let temp: Double
    let feels_like: Double
    let pressure: Int
    let humidity: Int
    let dew_point: Double
    let uvi: Double
    let clouds: Int
    let visibility: Int
    let wind_speed: Double
    let wind_deg: Int
    let wind_gust: Double?
    let weather: [Weather]
    let pop: Double // 강수 확률
    let rain: Rain? // 비 데이터
    let snow: Snow? // 눈 데이터
}

// 일별 날씨 모델
struct DailyWeather: Codable {
    let dt: Int
    let sunrise: Int
    let sunset: Int
    let moonrise: Int
    let moonset: Int
    let moon_phase: Double
    let summary: String?
    let temp: Temp
    let feels_like: FeelsLike
    let pressure: Int
    let humidity: Int
    let dew_point: Double
    let wind_speed: Double
    let wind_deg: Int
    let wind_gust: Double?
    let weather: [Weather]
    let clouds: Int
    let pop: Double
    let rain: Double? // 강수량 (mm 단위)
    let snow: Double? // 적설량 (mm 단위)
    let uvi: Double
}

// 온도 모델 (일별)
struct Temp: Codable {
    let day: Double
    let min: Double
    let max: Double
    let night: Double
    let eve: Double
    let morn: Double
}

// 체감 온도 모델 (일별)
struct FeelsLike: Codable {
    let day: Double
    let night: Double
    let eve: Double
    let morn: Double
}

// 공통 날씨 모델
struct Weather: Codable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

// 비 모델
struct Rain: Codable {
    let oneHour: Double? // 지난 1시간 동안의 강수량 (mm)
    let threeHour: Double? // 지난 3시간 동안의 강수량 (mm)

    enum CodingKeys: String, CodingKey {
        case oneHour = "1h"
        case threeHour = "3h"
    }
}

// 눈 모델
struct Snow: Codable {
    let oneHour: Double? // 지난 1시간 동안의 적설량 (mm)
    let threeHour: Double? // 지난 3시간 동안의 적설량 (mm)

    enum CodingKeys: String, CodingKey {
        case oneHour = "1h"
        case threeHour = "3h"
    }
}
