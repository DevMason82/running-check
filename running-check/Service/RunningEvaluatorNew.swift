//
//  RunningEvaluatorNew.swift
//  running-check
//
//  Created by mason on 11/25/24.
//

import Foundation

class RunningEvaluatorNew {
    static func evaluate(current: WeatherData) -> (grade: RunningGrade, coach: RunningCoach) {
        // 데이터 변환
        let feelsLike = Double(current.apparentTemperature.replacingOccurrences(of: "°C", with: "")) ?? 0
        let humidity = Double(current.humidity.replacingOccurrences(of: "%", with: "")) ?? 0
        let windSpeed = Double(current.windSpeed.components(separatedBy: " ").first ?? "") ?? 0
        let precipitationProbability = Double(current.precipitationProbability.replacingOccurrences(of: "%", with: "")) ?? 0
        let rainVolume = Double(current.temperature.replacingOccurrences(of: " mm", with: "")) ?? 0 // 강수량 (예시)
        let snowVolume = Double(current.temperature.replacingOccurrences(of: " mm", with: "")) ?? 0 // 적설량 (예시)
        let uvIndex = Double(current.conditionDescription.replacingOccurrences(of: " UV", with: "")) ?? 0 // UV Index (예시)

        // 위험 조건 확인
        let isHighRainProbability = precipitationProbability > 80
        let isHighRainVolume = rainVolume > 2.0
        let isHighSnowVolume = snowVolume > 2.0
        let isHighWind = windSpeed > 10.0
        let isTooCold = feelsLike < 5
        let isTooHot = feelsLike > 35
        let isHighUVIndex = uvIndex > 6.0

        // 위험 평가
        if isHighRainProbability || isHighRainVolume || isHighSnowVolume || isHighWind || isTooCold || isTooHot || isHighUVIndex {
            return (.danger, createDangerCoach(
                rainProbability: isHighRainProbability, rainVolume: isHighRainVolume,
                snowVolume: isHighSnowVolume, cold: isTooCold, hot: isTooHot,
                wind: isHighWind, uvIndex: isHighUVIndex,
                feelsLike: feelsLike, windSpeed: windSpeed, uvValue: uvIndex
            ))
        }

        // 경고 조건 확인
        if feelsLike < 10 || feelsLike > 30 || humidity > 80 || rainVolume > 1.0 || snowVolume > 1.0 || uvIndex > 5.0 {
            return (.warning, createWarningCoach(
                cold: feelsLike < 10, hot: feelsLike > 30, humid: humidity > 80,
                rainVolume: rainVolume > 1.0, snowVolume: snowVolume > 1.0,
                uvIndex: uvIndex > 5.0, feelsLike: feelsLike, humidity: humidity
            ))
        }

        // 좋은 날씨 평가
        return (.good, createGoodCoach(feelsLike: feelsLike))
    }
    
    private static func createDangerCoach(
        rainProbability: Bool, rainVolume: Bool, snowVolume: Bool, cold: Bool, hot: Bool, wind: Bool, uvIndex: Bool,
        feelsLike: Double, windSpeed: Double, uvValue: Double
    ) -> RunningCoach {
        var comment = "현재 날씨가 안전하지 않아 러닝을 삼가는 것이 좋습니다."
        var gear = "적절한 러닝 기어 준비"
        let shoes = "미끄럼 방지 기능이 있는 러닝화"
        var alternative = "실내 운동(예: 러닝머신, 요가, 웨이트 트레이닝)을 고려하세요."

        if rainProbability {
            comment = "강수 확률이 매우 높습니다. 비로 인해 노면이 미끄러울 수 있습니다."
            gear = "방수 러닝 재킷"
            alternative = "실내 러닝머신에서 러닝을 고려해 보세요."
        } else if rainVolume {
            comment = "강수량이 많아 노면이 미끄러울 수 있습니다. 안전에 주의하세요."
            gear = "방수 러닝 재킷"
            alternative = "비가 그친 후 러닝을 다시 계획해보세요."
        } else if snowVolume {
            comment = "적설량이 많아 눈길에서 러닝이 위험할 수 있습니다."
            gear = "보온성이 높은 러닝 의류"
            alternative = "눈이 녹은 후 안전한 노면에서 러닝을 추천합니다."
        } else if cold {
            comment = "체감온도가 \(feelsLike)°C로 매우 낮습니다. 근육 경직과 저체온증 위험이 있으니 실내에서 준비 운동을 해보세요."
            gear = "방한용 러닝 재킷과 장갑"
            alternative = "실내에서 스트레칭 후 러닝을 다시 계획하세요."
        } else if hot {
            comment = "체감온도가 \(feelsLike)°C로 매우 높습니다. 탈수와 열사병 위험이 있습니다."
            gear = "통기성이 우수한 경량 러닝 의류"
            alternative = "더 시원한 시간대에 러닝을 추천합니다."
        } else if wind {
            comment = "풍속이 \(windSpeed)m/s입니다. 강한 바람은 러닝에 영향을 줄 수 있습니다."
            gear = "방풍 재킷"
            alternative = "바람이 약해질 때 다시 시도해보세요."
        } else if uvIndex {
            comment = "자외선 지수가 \(uvValue)로 높습니다. 피부 손상 위험이 있으니 주의하세요."
            gear = "UV 차단 모자와 선글라스"
            alternative = "자외선이 약한 시간대에 러닝을 계획하세요."
        }

        return RunningCoach(comment: "\(comment)\n\n💡추천: \(alternative)", gear: gear, shoes: shoes)
    }

    private static func createWarningCoach(
        cold: Bool, hot: Bool, humid: Bool, rainVolume: Bool, snowVolume: Bool, uvIndex: Bool,
        feelsLike: Double, humidity: Double
    ) -> RunningCoach {
        var comment = "날씨가 다소 불편할 수 있지만, 주의하면 러닝이 가능합니다."
        var gear = "가벼운 방한복 또는 통기성 좋은 옷"
        let shoes = "접지력이 좋은 러닝화"
        var alternative = "적절한 시간대와 장소를 선택해 러닝을 계획하세요."

        if cold {
            comment = "체감온도가 \(feelsLike)°C입니다. 따뜻한 옷을 준비하세요."
            gear = "가벼운 방한복과 장갑"
            alternative = "추운 시간을 피하고 따뜻한 시간대에 러닝을 추천합니다."
        } else if hot {
            comment = "체감온도가 \(feelsLike)°C입니다. 더운 날씨에 수분 섭취를 충분히 하세요."
            gear = "통기성 좋은 옷과 모자"
            alternative = "더 시원한 시간대에 러닝을 추천합니다."
        } else if humid {
            comment = "습도가 \(humidity)%입니다. 땀 배출이 어려울 수 있으니 적절히 준비하세요."
            gear = "흡습성이 좋은 옷"
            alternative = "습도가 낮아질 시간대에 러닝을 계획하세요."
        } else if rainVolume {
            comment = "비가 조금 오고 있습니다. 미끄러움에 주의하세요."
            gear = "방수 러닝 재킷"
            alternative = "비가 그친 후 러닝을 추천합니다."
        } else if snowVolume {
            comment = "적설량이 있습니다. 눈길에 주의하세요."
            gear = "보온성이 높은 러닝 의류"
            alternative = "안전한 길에서 러닝을 고려해보세요."
        } else if uvIndex {
            comment = "자외선 지수가 약간 높습니다. 햇빛을 피하며 러닝하세요."
            gear = "UV 차단 모자와 선글라스"
            alternative = "아침이나 저녁 시간을 선택하세요."
        }

        return RunningCoach(comment: "\(comment)\n\n💡추천: \(alternative)", gear: gear, shoes: shoes)
    }

    private static func createGoodCoach(feelsLike: Double) -> RunningCoach {
        let comment: String
        let alternative: String

        if feelsLike < 15 {
            comment = "상쾌한 날씨입니다! 좋은 러닝을 즐길 수 있습니다."
            alternative = "야외에서 러닝하기 좋은 날씨입니다. 일정 거리를 목표로 해보세요."
        } else {
            comment = "러닝하기 완벽한 날씨입니다! 체력을 테스트해보세요."
            alternative = "공원이나 트랙에서 친구와 함께 러닝을 즐겨보세요."
        }

        return RunningCoach(
            comment: "\(comment)\n\n💡추천: \(alternative)",
            gear: "가벼운 러닝복과 모자",
            shoes: "쿠션감이 좋은 러닝화"
        )
    }
}
