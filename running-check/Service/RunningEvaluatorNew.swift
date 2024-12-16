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
//        var comment = "현재 날씨가 안전하지 않아 러닝을 삼가는 것이 좋습니다."
//        var gear = "적절한 러닝 기어 준비"
//        let shoes = "미끄럼 방지 기능이 있는 러닝화"
//        var alternative = "실내 운동(예: 러닝머신, 요가, 웨이트 트레이닝)을 고려하세요."
//
//        if rainProbability {
//            comment = "강수 확률이 매우 높습니다. 비로 인해 노면이 미끄러울 수 있습니다."
//            gear = "방수 러닝 재킷"
//            alternative = "실내 러닝머신에서 러닝을 고려해 보세요."
//        } else if rainVolume {
//            comment = "강수량이 많아 노면이 미끄러울 수 있습니다. 안전에 주의하세요."
//            gear = "방수 러닝 재킷"
//            alternative = "비가 그친 후 러닝을 다시 계획해보세요."
//        } else if snowVolume {
//            comment = "적설량이 많아 눈길에서 러닝이 위험할 수 있습니다."
//            gear = "보온성이 높은 러닝 의류"
//            alternative = "눈이 녹은 후 안전한 노면에서 러닝을 추천합니다."
//        } else if cold {
//            comment = "체감온도가 \(feelsLike)°C로 매우 낮습니다. 근육 경직과 저체온증 위험이 있으니 실내에서 준비 운동을 해보세요."
//            gear = "방한용 러닝 재킷과 장갑"
//            alternative = "실내에서 스트레칭 후 러닝을 다시 계획하세요."
//        } else if hot {
//            comment = "체감온도가 \(feelsLike)°C로 매우 높습니다. 탈수와 열사병 위험이 있습니다."
//            gear = "통기성이 우수한 경량 러닝 의류"
//            alternative = "더 시원한 시간대에 러닝을 추천합니다."
//        } else if wind {
//            comment = "풍속이 \(windSpeed)m/s입니다. 강한 바람은 러닝에 영향을 줄 수 있습니다."
//            gear = "방풍 재킷"
//            alternative = "바람이 약해질 때 다시 시도해보세요."
//        } else if uvIndex {
//            comment = "자외선 지수가 \(uvValue)로 높습니다. 피부 손상 위험이 있으니 주의하세요."
//            gear = "UV 차단 모자와 선글라스"
//            alternative = "자외선이 약한 시간대에 러닝을 계획하세요."
//        }
//
//        return RunningCoach(comment: "\(comment)\n\n💡추천: \(alternative)", gear: gear, shoes: shoes)
//    }
    
    private static func createDangerCoach(
        rainProbability: Bool, rainVolume: Bool, snowVolume: Bool, cold: Bool, hot: Bool, wind: Bool, uvIndex: Bool,
        feelsLike: Double, windSpeed: Double, uvValue: Double
    ) -> RunningCoach {
        var comment = "현재 날씨가 안전하지 않아 러닝을 삼가는 것이 좋습니다. 환경적 요인이 부상 위험을 높일 수 있습니다."
        var gear = "날씨에 적합한 러닝 기어 준비"
        let shoes = "미끄럼 방지 기능이 있는 러닝화 또는 환경에 적합한 신발"
        var alternative = "날씨 상황에 적합한 실내 운동(예: 러닝머신, 요가, 웨이트 트레이닝)을 시도해 보세요."

        if rainProbability {
            comment = """
            비가 올 가능성이 높습니다. 노면이 미끄러워 부상의 위험이 커질 수 있습니다.
            또한, 비를 맞으면 체온이 급격히 낮아져 근육 경직이나 저체온증이 발생할 수 있습니다.
            """
            gear = "방수 기능이 있는 러닝 재킷과 통기성이 좋은 모자"
            alternative = "실내 러닝머신을 이용하거나 비가 그친 후 러닝을 계획하세요."
        } else if rainVolume {
            comment = """
            강수량이 많아 노면이 미끄러울 수 있습니다. 비가 많이 내릴 경우, 가시성이 낮아져 교통사고의 위험도 있습니다.
            빗물은 체온 손실을 유발하며, 장시간 노출 시 저체온증 위험이 증가합니다.
            """
            gear = "완전 방수 러닝 재킷과 방수 신발"
            alternative = "비가 멈춘 뒤 노면이 마른 후 러닝을 추천합니다."
        } else if snowVolume {
            comment = """
            눈이 많이 쌓여 있는 환경에서는 발이 미끄러질 위험이 큽니다.
            특히 눈길은 발목과 무릎 관절에 불균형한 부담을 주어 부상의 가능성을 높입니다.
            또한, 신체가 열을 유지하려고 에너지를 추가로 소비하므로 피로감이 빨리 올 수 있습니다.
            """
            gear = "보온성이 높은 의류와 방수 신발"
            alternative = "눈이 녹은 뒤 안정된 환경에서 러닝을 추천합니다."
        } else if cold {
            comment = """
            현재 체감온도가 \(feelsLike)°C로 매우 낮습니다. 낮은 온도는 근육과 관절을 경직시켜 부상의 위험을 증가시킵니다.
            특히, 저체온증은 운동 능력을 떨어뜨리고 심각한 건강 문제를 초래할 수 있습니다.
            """
            gear = "보온용 러닝 재킷, 장갑, 보온 모자"
            alternative = """
            충분한 워밍업으로 근육을 이완시키고, 실내에서 러닝을 고려하거나 낮 시간대의 따뜻한 환경에서 러닝을 시도하세요.
            """
        } else if hot {
            comment = """
            체감온도가 \(feelsLike)°C로 매우 높습니다. 고온 환경에서는 탈수와 열사병 위험이 증가합니다.
            운동 중 땀 배출이 많아 전해질 불균형이 발생할 수 있으며, 이는 피로와 근육 경련으로 이어질 수 있습니다.
            """
            gear = "통기성이 우수한 경량 러닝 의류, 모자, 그리고 충분한 수분 보충을 위한 물병"
            alternative = """
            햇볕이 약한 시간대(이른 아침이나 늦은 저녁)에 러닝을 추천하며, 운동 전후로 충분한 수분과 전해질을 섭취하세요.
            """
        } else if wind {
            comment = """
            풍속이 \(windSpeed)m/s로 강풍이 불고 있습니다. 강한 바람은 체온 손실을 가속화하며, 러닝 자세를 흐트러뜨릴 수 있습니다.
            또한, 바람에 노출된 피부는 동상 위험이 증가할 수 있습니다.
            """
            gear = "방풍 재킷과 바람에 날리지 않는 고정력이 좋은 모자"
            alternative = """
            바람이 줄어든 시간대에 러닝하거나, 실내 러닝을 추천합니다.
            강풍이 부는 환경에서는 교통사고 위험도 높으니 주변 환경에 주의하세요.
            """
        } else if uvIndex {
            comment = """
            자외선 지수가 \(uvValue)로 매우 높습니다. 강한 자외선은 피부 손상과 열사병 위험을 증가시킬 수 있습니다.
            장시간 노출 시 피부암 발생 가능성이 증가할 수 있으니 주의하세요.
            """
            gear = "UV 차단 모자, 선글라스, 자외선 차단 크림"
            alternative = """
            자외선이 약한 아침이나 저녁 시간대에 러닝을 추천하며, 충분한 수분 섭취와 피부 보호를 잊지 마세요.
            """
        }

        return RunningCoach(
            comment: "\(comment)\n\n💡추천: \(alternative)",
            gear: gear,
            shoes: shoes
        )
    }

//    private static func createWarningCoach(
//        cold: Bool, hot: Bool, humid: Bool, rainVolume: Bool, snowVolume: Bool, uvIndex: Bool,
//        feelsLike: Double, humidity: Double
//    ) -> RunningCoach {
//        var comment = "날씨가 다소 불편할 수 있지만, 주의하면 러닝이 가능합니다."
//        var gear = "가벼운 방한복 또는 통기성 좋은 옷"
//        let shoes = "접지력이 좋은 러닝화"
//        var alternative = "적절한 시간대와 장소를 선택해 러닝을 계획하세요."
//
//        if cold {
//            comment = "체감온도가 \(feelsLike)°C입니다. 따뜻한 옷을 준비하세요."
//            gear = "가벼운 방한복과 장갑"
//            alternative = "추운 시간을 피하고 따뜻한 시간대에 러닝을 추천합니다."
//        } else if hot {
//            comment = "체감온도가 \(feelsLike)°C입니다. 더운 날씨에 수분 섭취를 충분히 하세요."
//            gear = "통기성 좋은 옷과 모자"
//            alternative = "더 시원한 시간대에 러닝을 추천합니다."
//        } else if humid {
//            comment = "습도가 \(humidity)%입니다. 땀 배출이 어려울 수 있으니 적절히 준비하세요."
//            gear = "흡습성이 좋은 옷"
//            alternative = "습도가 낮아질 시간대에 러닝을 계획하세요."
//        } else if rainVolume {
//            comment = "비가 조금 오고 있습니다. 미끄러움에 주의하세요."
//            gear = "방수 러닝 재킷"
//            alternative = "비가 그친 후 러닝을 추천합니다."
//        } else if snowVolume {
//            comment = "적설량이 있습니다. 눈길에 주의하세요."
//            gear = "보온성이 높은 러닝 의류"
//            alternative = "안전한 길에서 러닝을 고려해보세요."
//        } else if uvIndex {
//            comment = "자외선 지수가 약간 높습니다. 햇빛을 피하며 러닝하세요."
//            gear = "UV 차단 모자와 선글라스"
//            alternative = "아침이나 저녁 시간을 선택하세요."
//        }
//
//        return RunningCoach(comment: "\(comment)\n\n💡추천: \(alternative)", gear: gear, shoes: shoes)
//    }
    
    private static func createWarningCoach(
        cold: Bool, hot: Bool, humid: Bool, rainVolume: Bool, snowVolume: Bool, uvIndex: Bool,
        feelsLike: Double, humidity: Double
    ) -> RunningCoach {
        var comment = "날씨가 다소 불편할 수 있지만, 환경에 맞는 준비를 통해 안전하게 러닝할 수 있습니다."
        var gear = "날씨에 적합한 러닝 의류와 장비"
        let shoes = "접지력이 우수한 러닝화"
        var alternative = "날씨와 장소를 고려해 적절한 시간대를 선택해 러닝을 계획하세요."

        if cold {
            comment = """
            현재 체감온도가 \(feelsLike)°C로 다소 춥습니다. 저체온증과 근육 경직을 예방하려면 체온을 유지하는 것이 중요합니다.
            추운 날씨에는 몸을 따뜻하게 보호하면서 워밍업에 신경 쓰세요.
            """
            gear = "보온성이 있는 러닝 재킷, 장갑, 모자"
            alternative = "낮 시간대의 따뜻한 환경에서 러닝을 계획하세요. 충분한 워밍업 후 시작하세요."
        } else if hot {
            comment = """
            현재 체감온도가 \(feelsLike)°C로 더운 날씨입니다. 탈수와 열사병 위험이 있으니 물과 전해질을 충분히 섭취하세요.
            더운 날씨에서는 체온을 빠르게 낮추기 위한 통기성 좋은 옷이 필수입니다.
            """
            gear = "통기성 좋은 경량 러닝 의류와 모자"
            alternative = "햇볕이 약한 이른 아침이나 저녁 시간대에 러닝을 추천합니다."
        } else if humid {
            comment = """
            현재 습도가 \(humidity)%로 높아 땀이 증발하기 어려운 환경입니다. 높은 습도는 체온 조절을 방해하며 피로를 증가시킬 수 있습니다.
            흡습성이 좋은 옷을 선택하고 수분 보충에 신경 쓰세요.
            """
            gear = "흡습성이 우수한 통기성 러닝 의류"
            alternative = "습도가 낮은 시간대(아침 또는 저녁)에 러닝을 계획하세요."
        } else if rainVolume {
            comment = """
            현재 비가 약간 내리고 있습니다. 노면이 미끄러울 수 있으니 발을 디딜 때 주의하세요.
            빗속 러닝은 재미있을 수 있지만, 체온 손실에 대비해야 합니다.
            """
            gear = "가벼운 방수 러닝 재킷과 모자"
            alternative = "비가 멈춘 후 러닝을 추천하거나, 주변 환경에 주의하며 러닝하세요."
        } else if snowVolume {
            comment = """
            현재 적설량이 있어 눈길에서의 미끄럼 위험이 있습니다. 발목과 관절 부상의 가능성을 줄이기 위해 안전한 길을 선택하세요.
            눈길은 에너지 소비가 많아질 수 있으니 평소보다 더 준비가 필요합니다.
            """
            gear = "보온성과 방수 기능이 있는 러닝 의류"
            alternative = "제설된 안전한 길에서 러닝하거나, 실내 러닝을 고려하세요."
        } else if uvIndex {
            comment = """
            현재 자외선 지수가 다소 높습니다. 자외선은 피부 손상과 눈의 피로를 유발할 수 있습니다.
            장시간 노출 시 피부 보호를 위해 차단제를 사용하세요.
            """
            gear = "UV 차단 모자, 선글라스, 그리고 SPF가 높은 자외선 차단 크림"
            alternative = "자외선이 약한 아침이나 저녁 시간대에 러닝을 추천합니다."
        }

        return RunningCoach(
            comment: "\(comment)\n\n💡추천: \(alternative)",
            gear: gear,
            shoes: shoes
        )
    }

//    private static func createGoodCoach(feelsLike: Double) -> RunningCoach {
//        let comment: String
//        let alternative: String
//
//        if feelsLike < 15 {
//            comment = "상쾌한 날씨입니다! 좋은 러닝을 즐길 수 있습니다."
//            alternative = "야외에서 러닝하기 좋은 날씨입니다. 일정 거리를 목표로 해보세요."
//        } else {
//            comment = "러닝하기 완벽한 날씨입니다! 체력을 테스트해보세요."
//            alternative = "공원이나 트랙에서 친구와 함께 러닝을 즐겨보세요."
//        }
//
//        return RunningCoach(
//            comment: "\(comment)\n\n💡추천: \(alternative)",
//            gear: "가벼운 러닝복과 모자",
//            shoes: "쿠션감이 좋은 러닝화"
//        )
//    }
    
    private static func createGoodCoach(feelsLike: Double) -> RunningCoach {
        let comment: String
        let alternative: String
        let gear: String

        if feelsLike < 15 {
            comment = """
            상쾌한 날씨입니다! 기온이 낮아 체온 조절이 용이하고, 장거리 러닝에 적합합니다.
            이 온도에서는 근육 온도가 적절히 유지되며, 퍼포먼스를 극대화하기 좋은 환경입니다.
            """
            alternative = "야외에서 일정 거리를 목표로 장거리 러닝을 시도해보세요. 페이스 조절을 통해 체력을 테스트해 보세요."
            gear = "얇은 긴팔 러닝복 또는 반팔 러닝복, 가벼운 모자"
        } else if feelsLike <= 25 {
            comment = """
            러닝하기 완벽한 날씨입니다! 기온이 적당해 심박수 관리와 땀 배출이 용이합니다.
            이 환경에서는 유산소 운동의 효과를 최대한 누릴 수 있습니다.
            """
            alternative = "공원이나 트랙에서 친구와 함께 러닝을 즐기거나, 일정 속도를 목표로 인터벌 러닝을 시도해보세요."
            gear = "통기성이 좋은 반팔 러닝복과 모자"
        } else {
            comment = """
            따뜻한 날씨입니다! 체온 조절을 위해 수분 보충에 신경 쓰며 적당한 강도의 러닝을 즐길 수 있습니다.
            땀이 많이 나는 환경에서는 근육 순환이 활성화되어 피로 회복 속도를 높일 수 있습니다.
            """
            alternative = "아침이나 저녁 시간대를 선택하여 짧은 러닝을 시도하고, 중간에 수분 섭취를 잊지 마세요."
            gear = "통기성이 뛰어난 러닝복, 밝은 색상의 모자"
        }

        return RunningCoach(
            comment: "\(comment)\n\n💡추천: \(alternative)",
            gear: gear,
            shoes: "쿠션감이 좋은 러닝화"
        )
    }
}
