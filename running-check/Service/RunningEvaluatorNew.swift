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

//    private static func createDangerCoach(
//        rainProbability: Bool, rainVolume: Bool, snowVolume: Bool, cold: Bool, hot: Bool, wind: Bool, uvIndex: Bool,
//        feelsLike: Double, windSpeed: Double, uvValue: Double
//    ) -> RunningCoach {
//        var comment = "러닝을 삼가는 것이 좋습니다. 안전이 최우선입니다."
//        var gear = "방수 재킷, 방풍 장갑"
//        let shoes = "미끄럼 방지 기능이 있는 러닝화"
//
//        if rainProbability {
//            comment = "강수 확률이 매우 높습니다. 비로 인해 노면이 미끄러울 수 있습니다."
//            gear = "방수 러닝 재킷"
//        } else if rainVolume {
//            comment = "강수량이 많아 노면이 미끄러울 수 있습니다."
//            gear = "방수 러닝 재킷"
//        } else if snowVolume {
//            comment = "적설량이 많아 눈길에서 러닝이 위험할 수 있습니다."
//            gear = "보온성이 높은 러닝 의류"
//        } else if cold {
//            comment = "체감온도가 \(feelsLike)°C로 너무 낮습니다. 근육 경직과 저체온증의 위험이 있습니다."
//            gear = "방한용 러닝 재킷과 장갑"
//        } else if hot {
//            comment = "체감온도가 \(feelsLike)°C로 너무 높습니다. 탈수와 열사병 위험이 있습니다."
//            gear = "통기성이 우수한 경량 러닝 의류"
//        } else if wind {
//            comment = "풍속이 \(windSpeed)m/s입니다. 강한 바람은 러닝에 위험할 수 있습니다."
//            gear = "방풍 재킷"
//        } else if uvIndex {
//            comment = "자외선 지수가 \(uvValue)로 매우 높아 피부 손상과 탈수 위험이 있습니다. 자외선 차단제를 사용하고, UV 차단 모자와 선글라스를 착용하세요."
//            gear = "UV 차단 모자와 선글라스"
//        }
//
//        return RunningCoach(comment: comment, gear: gear, shoes: shoes)
//    }
    
    private static func createDangerCoach(
        rainProbability: Bool, rainVolume: Bool, snowVolume: Bool, cold: Bool, hot: Bool, wind: Bool, uvIndex: Bool,
        feelsLike: Double, windSpeed: Double, uvValue: Double
    ) -> RunningCoach {
        var comment = "러닝을 삼가는 것이 좋습니다. 안전이 최우선입니다."
        var gear = "방수 재킷, 방풍 장갑"
        let shoes = "미끄럼 방지 기능이 있는 러닝화"
        var alternative = "실내 운동(예: 러닝머신, 요가, 웨이트 트레이닝)을 고려하세요."

        if rainProbability {
            comment = "강수 확률이 매우 높습니다. 비로 인해 노면이 미끄러울 수 있습니다."
            gear = "방수 러닝 재킷"
            alternative = "실내 러닝머신에서 러닝하거나, 스텝 운동을 시도하세요."
        } else if rainVolume {
            comment = "강수량이 많아 노면이 미끄러울 수 있습니다."
            gear = "방수 러닝 재킷"
            alternative = "비가 그친 후 러닝을 계획하거나, 실내에서 근력 운동을 해보세요."
        } else if snowVolume {
            comment = "적설량이 많아 눈길에서 러닝이 위험할 수 있습니다."
            gear = "보온성이 높은 러닝 의류"
            alternative = "눈이 녹을 때까지 기다리거나, 실내 워킹머신을 사용하는 것이 좋습니다."
        } else if cold {
            comment = "체감온도가 \(feelsLike)°C로 너무 낮습니다. 근육 경직과 저체온증의 위험이 있습니다."
            gear = "방한용 러닝 재킷과 장갑"
            alternative = "따뜻한 실내에서 스트레칭이나 HIIT(고강도 인터벌 트레이닝)를 시도하세요."
        } else if hot {
            comment = "체감온도가 \(feelsLike)°C로 너무 높습니다. 탈수와 열사병 위험이 있습니다."
            gear = "통기성이 우수한 경량 러닝 의류"
            alternative = "아침 일찍이나 저녁 늦게 더 시원할 때 러닝을 하거나, 수영과 같은 실내 운동을 고려하세요."
        } else if wind {
            comment = "풍속이 \(windSpeed)m/s입니다. 강한 바람은 러닝에 위험할 수 있습니다."
            gear = "방풍 재킷"
            alternative = "바람이 약해질 때까지 기다리거나, 실내 운동을 하세요."
        } else if uvIndex {
            comment = "자외선 지수가 \(uvValue)로 매우 높아 피부 손상과 탈수 위험이 있습니다. 자외선 차단제를 사용하고, UV 차단 모자와 선글라스를 착용하세요."
            gear = "UV 차단 모자와 선글라스"
            alternative = "자외선이 약한 시간대(아침 일찍이나 저녁 늦게)로 러닝 일정을 조정하거나, 실내 운동을 고려하세요."
        }

        return RunningCoach(comment: "\(comment)\n\n💡추천: \(alternative)", gear: gear, shoes: shoes)
    }

//    private static func createWarningCoach(
//        cold: Bool, hot: Bool, humid: Bool, rainVolume: Bool, snowVolume: Bool, uvIndex: Bool,
//        feelsLike: Double, humidity: Double
//    ) -> RunningCoach {
//        var comment = "날씨가 적당하지 않을 수 있습니다. 준비를 철저히 하세요."
//        var gear = "가벼운 방한복 또는 통기성 좋은 옷"
//        let shoes = "접지력이 좋은 러닝화"
//
//        if cold {
//            comment = "체감온도가 \(feelsLike)°C입니다. 추운 날씨에 보온에 유의하세요."
//            gear = "가벼운 방한복과 러닝 장갑"
//        } else if hot {
//            comment = "체감온도가 \(feelsLike)°C입니다. 더운 날씨에 수분 섭취를 충분히 하세요."
//            gear = "통기성 좋은 옷과 모자"
//        } else if humid {
//            comment = "습도가 \(humidity)%입니다. 높은 습도로 인해 체온 조절이 어렵습니다."
//            gear = "흡습성이 좋은 옷"
//        } else if rainVolume {
//            comment = "강수량이 적당히 많습니다. 미끄러운 노면에 주의하세요."
//            gear = "방수 러닝 재킷"
//        } else if snowVolume {
//            comment = "적설량이 적당히 많습니다. 미끄럼 방지 신발을 착용하세요."
//            gear = "보온성이 높은 러닝 의류"
//        } else if uvIndex {
//            comment = "자외선 지수가 약간 높습니다. 햇빛을 피하며 러닝하세요."
//            gear = "UV 차단 모자와 선글라스"
//        }
//
//        return RunningCoach(comment: comment, gear: gear, shoes: shoes)
//    }
    
    private static func createWarningCoach(
        cold: Bool, hot: Bool, humid: Bool, rainVolume: Bool, snowVolume: Bool, uvIndex: Bool,
        feelsLike: Double, humidity: Double
    ) -> RunningCoach {
        var comment = "날씨가 적당하지 않을 수 있습니다. 준비를 철저히 하세요."
        var gear = "가벼운 방한복 또는 통기성 좋은 옷"
        let shoes = "접지력이 좋은 러닝화"
        var alternative = "적절한 시간대와 장소를 선택해 러닝을 계획하세요."

        if cold {
            comment = "체감온도가 \(feelsLike)°C입니다. 추운 날씨에 보온에 유의하세요."
            gear = "가벼운 방한복과 러닝 장갑"
            alternative = "러닝 시간을 낮 시간대로 조정하거나 실내 러닝머신을 사용해보세요."
        } else if hot {
            comment = "체감온도가 \(feelsLike)°C입니다. 더운 날씨에 수분 섭취를 충분히 하세요."
            gear = "통기성 좋은 옷과 모자"
            alternative = "아침 일찍이나 저녁 늦게 더 시원한 시간에 러닝을 해보세요. 또는 실내 운동을 고려하세요."
        } else if humid {
            comment = "습도가 \(humidity)%입니다. 높은 습도로 인해 체온 조절이 어렵습니다."
            gear = "흡습성이 좋은 옷"
            alternative = "습도가 낮아지는 시간을 선택하거나, 실내에서 러닝을 고려하세요."
        } else if rainVolume {
            comment = "강수량이 적당히 많습니다. 미끄러운 노면에 주의하세요."
            gear = "방수 러닝 재킷"
            alternative = "비가 그친 후 러닝을 시도하거나, 실내 운동을 고려하세요."
        } else if snowVolume {
            comment = "적설량이 적당히 많습니다. 미끄럼 방지 신발을 착용하세요."
            gear = "보온성이 높은 러닝 의류"
            alternative = "눈이 녹은 후 안전한 노면에서 러닝하거나, 실내 러닝머신을 사용하세요."
        } else if uvIndex {
            comment = "자외선 지수가 약간 높습니다. 햇빛을 피하며 러닝하세요."
            gear = "UV 차단 모자와 선글라스"
            alternative = "자외선이 약해지는 아침 일찍이나 저녁 늦게 러닝을 해보세요."
        }

        return RunningCoach(comment: "\(comment)\n\n💡추천: \(alternative)", gear: gear, shoes: shoes)
    }

//    private static func createGoodCoach(feelsLike: Double) -> RunningCoach {
//        let comment = feelsLike < 15
//            ? "상쾌한 날씨입니다. 겨울철 러닝은 지방 연소율을 높이고 면역 체계를 강화할 수 있습니다!"
//            : "러닝하기에 최적의 날씨입니다. 지방 연소와 심폐 기능 강화에 좋은 환경입니다."
//        return RunningCoach(comment: comment, gear: "가벼운 러닝복과 모자", shoes: "쿠션감이 좋은 러닝화")
//    }
    private static func createGoodCoach(feelsLike: Double) -> RunningCoach {
        let comment: String
        let alternative: String

        if feelsLike < 15 {
            comment = "상쾌한 날씨입니다. 겨울철 러닝은 지방 연소율을 높이고 면역 체계를 강화할 수 있습니다!"
            alternative = "추운 날씨를 활용해 낮 시간대의 상쾌한 러닝을 즐기세요. 또는 가벼운 조깅으로 시작해보세요."
        } else {
            comment = "러닝하기에 최적의 날씨입니다. 지방 연소와 심폐 기능 강화에 좋은 환경입니다."
            alternative = "야외 공원이나 러닝 트랙에서 일정 거리를 목표로 러닝을 계획하세요. 친구와 함께 러닝도 추천합니다."
        }

        return RunningCoach(
            comment: "\(comment)\n\n💡추천: \(alternative)",
            gear: "가벼운 러닝복과 모자",
            shoes: "쿠션감이 좋은 러닝화"
        )
    }
}
