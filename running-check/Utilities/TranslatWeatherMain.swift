//
//  TranslatWeather.swift
//  running-check
//
//  Created by mason on 11/25/24.
//

import Foundation

private func translateWeatherMain(_ main: String) -> String {
    switch main {
    case "Clear":
        return "맑음"
    case "Clouds":
        return "흐림"
    case "Rain":
        return "비"
    case "Drizzle":
        return "이슬비"
    case "Thunderstorm":
        return "뇌우"
    case "Snow":
        return "눈"
    case "Mist":
        return "안개"
    case "Smoke":
        return "연기"
    case "Haze":
        return "연무"
    case "Dust":
        return "먼지"
    case "Fog":
        return "짙은 안개"
    case "Sand":
        return "모래"
    case "Ash":
        return "재"
    case "Squall":
        return "돌풍"
    case "Tornado":
        return "토네이도"
    default:
        return main // 기본적으로 원래 값 반환
    }
}
