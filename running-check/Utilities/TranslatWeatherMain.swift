//
//  TranslatWeather.swift
//  running-check
//
//  Created by mason on 11/25/24.
//

import Foundation

func translateWeatherMain(_ main: String) -> String {
    switch main {
    case "Clear":
        return "맑음"
    case "Mostly Clear":
        return "대체로 맑음"
    case "Partly Cloudy":
        return "부분적으로 흐림"
    case "Mostly Cloudy":
        return "대체로 흐림"
    case "Cloudy":
        return "흐림"
    case "Drizzle":
        return "이슬비"
    case "Rain":
        return "비"
    case "Heavy Rain":
        return "폭우"
    case "Showers":
        return "소나기"
    case "Flurries":
        return "눈발 날림"
    case "Snow":
        return "눈"
    case "Heavy Snow":
        return "폭설"
    case "Blizzard":
        return "눈보라"
    case "Fog":
        return "짙은 안개"
    case "Haze":
        return "연무"
    case "Smoke":
        return "연기"
    case "Dust":
        return "먼지"
    case "Sand":
        return "모래"
    case "Ash":
        return "재"
    case "Squall":
        return "돌풍"
    case "Thunderstorms":
        return "뇌우"
    case "Tornado":
        return "토네이도"
    default:
        return main // 기본적으로 원래 값 반환
    }
}
