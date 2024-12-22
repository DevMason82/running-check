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
        var comment = "현재 날씨가 안전하지 않아 러닝을 삼가는 것이 좋습니다. 환경적 요인이 부상 위험을 높일 수 있습니다."
        var gear = "날씨에 적합한 러닝 기어 준비"
        var shoes = "미끄럼 방지 기능이 있는 러닝화 또는 환경에 적합한 신발"
        var alternative = "날씨 상황에 적합한 실내 운동(예: 러닝머신, 요가, 웨이트 트레이닝)을 시도해 보세요."
        
        // 초보 러너를 위한 간단 피드백
        var simpleFeedback = "현재 날씨가 좋지 않습니다. 실내 운동을 추천합니다."

        if rainProbability {
            comment = """
            비가 올 가능성이 높습니다. 노면이 미끄러워 부상의 위험이 커질 수 있습니다.
            또한, 비를 맞으면 체온이 급격히 낮아져 근육 경직이나 저체온증이 발생할 수 있습니다.
            """
            gear = """
            - 방수 기능이 있는 러닝 재킷: 비를 막아주며 통기성이 좋은 재질.
            - 통기성이 좋은 모자: 빗물이 얼굴로 흐르지 않게 도와줌.
            - 방수 방한 장갑: 손을 따뜻하게 유지하며 빗물 차단.
            """
            shoes = """
            - 방수 기능이 있는 러닝화: 비를 막고 발을 보호.
            - 접지력이 뛰어난 러닝화: 미끄러짐 방지.
            """
            alternative = "실내 러닝머신을 이용하거나 비가 그친 후 러닝을 계획하세요."
            simpleFeedback = "비가 예상됩니다. 실내 러닝 추천!"

        } else if rainVolume {
            comment = """
            강수량이 많아 노면이 미끄러울 수 있습니다. 비가 많이 내릴 경우, 가시성이 낮아져 교통사고의 위험도 있습니다.
            빗물은 체온 손실을 유발하며, 장시간 노출 시 저체온증 위험이 증가합니다.
            """
            gear = """
            - 완전 방수 러닝 재킷: 높은 강수량에서도 신체를 완벽히 보호.
            - 방수 바지: 하체와 발목 부분을 젖지 않게 유지.
            - 방수 신발 커버: 신발 안으로 물이 들어오는 것을 방지.
            """
            shoes = """
            - 방수 러닝화 또는 신발 커버: 빗물 차단 필수.
            """
            alternative = "비가 멈춘 뒤 노면이 마른 후 러닝을 추천합니다."
            simpleFeedback = "비가 많이 내립니다. 러닝 삼가세요."

        } else if snowVolume {
            comment = """
            눈이 많이 쌓여 있는 환경에서는 발이 미끄러질 위험이 큽니다.
            특히 눈길은 발목과 무릎 관절에 불균형한 부담을 주어 부상의 가능성을 높입니다.
            또한, 신체가 열을 유지하려고 에너지를 추가로 소비하므로 피로감이 빨리 올 수 있습니다.
            """
            gear = """
            - 보온성이 높은 러닝 재킷: 체온 유지를 위해 필수.
            - 방수 러닝 팬츠: 눈과 접촉을 최소화.
            - 목도리 또는 넥 게이터: 찬 공기로부터 목 보호.
            """
            shoes = """
            - 스터드가 있는 러닝화: 미끄러짐 방지 기능.
            - 방수 처리된 러닝화: 눈으로 인해 젖지 않도록 보호.
            """
            alternative = "눈이 녹은 뒤 안정된 환경에서 러닝을 추천합니다."
            simpleFeedback = "눈이 옵니다. 실내 운동 추천!"

        } else if cold {
            comment = """
            현재 체감온도가 \(feelsLike)°C로 매우 낮습니다. 낮은 온도는 근육과 관절을 경직시켜 부상의 위험을 증가시킵니다.
            특히, 저체온증은 운동 능력을 떨어뜨리고 심각한 건강 문제를 초래할 수 있습니다.
            """
            gear = """
            - 보온용 러닝 재킷: 내부에 열을 가두는 기술을 가진 옷.
            - 방한 장갑: 손끝이 얼지 않도록 보호.
            - 보온 모자: 머리와 귀를 따뜻하게 유지.
            """
            shoes = """
            - 방한 러닝화: 발을 따뜻하게 유지.
            - 방수 러닝화: 눈이나 얼음으로 인해 젖지 않도록 보호.
            """
            alternative = """
            충분한 워밍업으로 근육을 이완시키고, 실내에서 러닝을 고려하거나 낮 시간대의 따뜻한 환경에서 러닝을 시도하세요.
            """
            simpleFeedback = "날씨가 춥습니다. 워밍업 후 짧게 러닝!"

        } else if hot {
            comment = """
            체감온도가 \(feelsLike)°C로 매우 높습니다. 고온 환경에서는 탈수와 열사병 위험이 증가합니다.
            """
            gear = """
            - 통기성이 우수한 경량 러닝 의류: 땀 배출을 용이하게 함.
            - 모자: 태양의 직사광선을 차단.
            - 휴대용 물병 또는 수분 백팩: 러닝 중 지속적인 수분 섭취 가능.
            """
            shoes = """
            - 통기성이 좋은 메쉬 러닝화: 발의 열 배출을 도와줌.
            """
            alternative = """
            햇볕이 약한 시간대(이른 아침이나 늦은 저녁)에 러닝을 추천합니다.
            """
            simpleFeedback = "더운 날씨입니다. 물 자주 마시고 짧게 러닝!"

        }
        
        return RunningCoach(
            simpleFeedback: simpleFeedback,
            comment: comment,
            alternative: alternative,
            gear: gear,
            shoes: shoes
        )
    }
        
    private static func createWarningCoach(
        cold: Bool, hot: Bool, humid: Bool, rainVolume: Bool, snowVolume: Bool, uvIndex: Bool,
        feelsLike: Double, humidity: Double
    ) -> RunningCoach {
        var comment = "날씨가 다소 불편할 수 있지만, 환경에 맞는 준비를 통해 안전하게 러닝할 수 있습니다."
        var gear = "날씨에 적합한 러닝 의류와 장비를 준비하세요."
        var shoes = "접지력과 쿠셔닝이 뛰어난 러닝화"
        var alternative = "날씨와 장소를 고려해 적절한 시간대를 선택해 러닝을 계획하세요."
        
        // 초보 러너 메시지
        var simpleFeedback = "기본 수칙: 편안하게, 짧게, 천천히 시작하세요!"

        if cold {
            comment = """
            현재 체감온도가 \(feelsLike)°C로 다소 춥습니다. 근육이 경직되기 쉬우니 체온을 유지하고 충분히 워밍업하세요.
            추운 환경에서는 피부 노출을 최소화하고, 몸의 열을 유지하는 것이 중요합니다.
            """
            gear = """
            - 보온 기능이 뛰어난 러닝 재킷: 바람을 막고 체온을 유지.
            - 방한 장갑과 모자: 손과 머리를 따뜻하게 보호.
            - 기모 소재의 러닝 팬츠: 하체 보온 필수.
            """
            shoes = """
            - 방수 및 방한 기능 러닝화: 발을 따뜻하게 유지하고 눈이나 물이 스며들지 않도록 보호.
            - 발목을 덮는 러닝화 추천: 보온성과 안정성을 높임.
            """
            alternative = "낮 시간대의 따뜻한 시간에 러닝하거나 실내 러닝을 고려하세요."
            simpleFeedback = "춥습니다! 워밍업 필수, 보온 장비 착용 후 짧게 달리세요."
            
        } else if hot {
            comment = """
            현재 체감온도가 \(feelsLike)°C로 덥습니다. 더운 날씨에는 열사병과 탈수에 주의하세요.
            수분과 전해질 섭취에 신경 쓰고 통기성이 좋은 옷을 입으세요.
            """
            gear = """
            - 통기성이 우수한 반팔/반바지 러닝복: 땀을 빠르게 배출.
            - UV 차단 모자: 태양광 차단.
            - 휴대용 물병: 수분 보충 필수.
            """
            shoes = """
            - 통기성이 우수한 메쉬 러닝화: 발의 열을 배출하고 쾌적함을 유지.
            - 밝은 색상의 러닝화: 태양광 흡수를 줄여 발의 온도를 낮춤.
            """
            alternative = "햇볕이 약한 이른 아침이나 늦은 저녁 시간에 러닝을 추천합니다."
            simpleFeedback = "더웁습니다! 짧게 달리기 + 물 자주 마시세요."

        } else if humid {
            comment = """
            현재 습도가 \(humidity)%로 높습니다. 땀이 증발하지 않아 체온 조절이 어렵습니다.
            높은 습도에서는 체력 소모가 빠르므로 속도를 조절하고 수분을 충분히 섭취하세요.
            """
            gear = """
            - 흡습성이 뛰어난 러닝복: 땀을 빠르게 흡수 및 배출.
            - 땀 흡수를 위한 헤드밴드: 이마의 땀을 방지.
            """
            shoes = """
            - 통기성이 우수한 러닝화: 습한 환경에서도 발이 답답하지 않도록.
            - 흡습 패드 또는 인솔: 발 땀을 흡수해 쾌적하게 유지.
            """
            alternative = "습도가 낮은 시간대(아침 또는 저녁)에 러닝을 시도하거나 실내 운동을 고려하세요."
            simpleFeedback = "습합니다! 천천히 달리기, 자주 휴식하세요."

        } else if rainVolume {
            comment = """
            현재 약한 비가 내리고 있습니다. 노면이 미끄러울 수 있으니 발을 디딜 때 주의하세요.
            비에 젖는 것을 방지하고 체온 손실에 대비하세요.
            """
            gear = """
            - 가벼운 방수 재킷: 비를 막으면서 통기성 유지.
            - 방수 모자: 얼굴에 빗물이 흐르는 것을 방지.
            """
            shoes = """
            - 방수 기능이 있는 러닝화: 비를 막고 발이 젖지 않도록 보호.
            - 접지력이 좋은 러닝화: 미끄러운 길에서도 안정적으로 달릴 수 있도록.
            """
            alternative = "비가 멈춘 후 러닝을 추천하거나 실내 러닝머신을 이용해보세요."
            simpleFeedback = "비가 옵니다! 실내 러닝 추천, 외부는 조심히."

        } else if snowVolume {
            comment = """
            현재 눈이 내리고 있어 노면이 미끄럽습니다. 발을 디딜 때 주의하고, 미끄러지지 않는 신발을 착용하세요.
            에너지 소비가 많아질 수 있으므로 준비 운동을 철저히 하세요.
            """
            gear = """
            - 방수 및 보온 러닝 재킷: 체온을 유지하고 눈에 젖지 않도록 보호.
            - 발목을 보호하는 러닝 팬츠: 하체를 따뜻하게 유지.
            """
            shoes = """
            - 스터드(미끄럼 방지) 기능 러닝화: 눈길에서 미끄러짐 방지.
            - 방수 처리된 러닝화: 눈으로 인해 젖는 것을 방지.
            """
            alternative = "눈이 제설된 안전한 길에서 러닝하거나 실내 러닝머신을 이용하세요."
            simpleFeedback = "눈이 옵니다! 짧게 달리기, 미끄럼 방지 신발 필수."

        } else if uvIndex {
            comment = """
            현재 자외선 지수가 높습니다. 피부 손상과 눈의 피로를 방지하기 위해 보호 장비를 착용하세요.
            장시간 노출을 피하고, 피부를 보호하는 것이 중요합니다.
            """
            gear = """
            - UV 차단 모자와 선글라스: 태양광 차단 및 눈 보호.
            - SPF 50+ 자외선 차단제: 피부 보호 필수.
            """
            shoes = """
            - 밝은 색상의 러닝화: 열 흡수를 줄이고 쾌적함 유지.
            - 통기성 높은 러닝화: 발 과열 방지.
            """
            alternative = "자외선이 약한 아침이나 저녁 시간대에 러닝을 계획하세요."
            simpleFeedback = "자외선 강함! 모자, 썬크림 필수, 짧게 러닝하세요."
        }

        return RunningCoach(
            simpleFeedback: simpleFeedback,
            comment: comment,
            alternative: alternative,
            gear: gear,
            shoes: shoes
        )
    }
    
    private static func createGoodCoach(feelsLike: Double) -> RunningCoach {
        let comment: String
        let alternative: String
        let gear: String
        
        // 초보 러너를 위한 심플 메시지
        var simpleFeedback = "지금 러닝하기 좋은 날씨입니다! 편안하게 달리세요."

        if feelsLike < 15 {
            comment = """
            상쾌한 날씨입니다! 기온이 낮아 체온 조절이 용이하며, 장거리 러닝이나 고강도 훈련에 적합한 환경입니다.
            이 온도에서는 근육의 이상적인 온도를 유지할 수 있어 퍼포먼스를 극대화할 수 있습니다.
            """
            alternative = """
            야외에서 장거리 러닝이나 페이스 테스트를 진행해보세요. 꾸준한 호흡과 워밍업을 통해 최고의 성과를 낼 수 있습니다.
            """
            gear = """
            - 얇은 긴팔 러닝복: 체온 조절을 도와줍니다.
            - 가벼운 러닝 재킷: 초반 체온을 보호하고 땀 배출이 용이한 재질 추천.
            - 가벼운 모자: 체온 손실 방지와 햇볕 차단.
            """
            simpleFeedback = "상쾌한 날씨! 긴 팔 러닝복으로 편하게 달리세요."

        } else if feelsLike <= 25 {
            comment = """
            러닝하기 완벽한 날씨입니다! 적당한 기온 덕분에 체온 관리가 용이하며, 땀 배출도 최적화됩니다.
            유산소 운동의 효과를 극대화할 수 있는 환경입니다.
            """
            alternative = """
            공원이나 트랙에서 친구와 함께 러닝을 즐겨보세요. 일정 속도를 목표로 인터벌 러닝을 시도하거나, 다양한 페이스 변화를 연습하기 좋습니다.
            """
            gear = """
            - 통기성이 좋은 반팔 러닝복: 땀을 빠르게 배출하고 쾌적한 러닝 환경 제공.
            - 경량 모자: 햇볕 차단과 열 배출.
            - 스마트 워치: 페이스와 심박수를 확인하며 효율적으로 러닝.
            """
            simpleFeedback = "완벽한 날씨! 반팔 러닝복으로 가볍게 달리세요."

        } else {
            comment = """
            따뜻한 날씨입니다! 체온이 상승하기 쉬운 환경이므로 수분 섭취와 적절한 휴식을 병행하며 러닝을 즐기세요.
            이 환경에서는 근육 순환이 활성화되어 피로 회복 속도를 높이는 데 유리합니다.
            """
            alternative = """
            햇볕이 약한 이른 아침이나 늦은 저녁 시간대를 선택하세요. 짧은 러닝을 시도하며 중간에 수분 섭취를 잊지 마세요.
            """
            gear = """
            - 통기성이 뛰어난 반팔/반바지 러닝복: 땀 배출에 최적화.
            - 밝은 색상의 모자: 열 흡수를 줄이고 햇볕을 차단.
            - 물병 또는 수분 백팩: 지속적인 수분 섭취를 위한 필수 아이템.
            """
            simpleFeedback = "따뜻한 날씨! 물 자주 마시고 가볍게 달리세요."
        }

        return RunningCoach(
            simpleFeedback: simpleFeedback,
            comment: comment,
            alternative: alternative,
            gear: gear,
            shoes: """
            - 쿠션감이 좋은 러닝화: 충격 흡수와 발 피로 감소.
            - 통기성이 우수한 러닝화: 발에 쾌적함을 유지.
            """
        )
    }
}
