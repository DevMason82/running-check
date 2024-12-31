//
//  RunningEvaluatorNew.swift
//  running-check
//
//  Created by mason on 11/25/24.
//

import Foundation

class RunningEvaluatorNew {
//    static func evaluate(current: WeatherData) -> (grade: RunningGrade, coach: RunningCoach) {
//        // 데이터 변환
//        let feelsLike = Double(current.apparentTemperature.replacingOccurrences(of: "°C", with: "")) ?? 0
//        let humidity = Double(current.humidity.replacingOccurrences(of: "%", with: "")) ?? 0
//        let windSpeed = Double(current.windSpeed.components(separatedBy: " ").first ?? "") ?? 0
//        let precipitationProbability = Double(current.precipitationProbability.replacingOccurrences(of: "%", with: "")) ?? 0
//        let rainVolume = Double(current.temperature.replacingOccurrences(of: " mm", with: "")) ?? 0 // 강수량 (예시)
//        let snowVolume = Double(current.temperature.replacingOccurrences(of: " mm", with: "")) ?? 0 // 적설량 (예시)
//        let uvIndex = Double(current.conditionDescription.replacingOccurrences(of: " UV", with: "")) ?? 0 // UV Index (예시)
//        
//        // 위험 조건 확인
//        let isHighRainProbability = precipitationProbability > 80
//        let isHighRainVolume = rainVolume > 2.0
//        let isHighSnowVolume = snowVolume > 2.0
//        let isHighWind = windSpeed > 10.0
//        let isTooCold = feelsLike < 5
//        let isTooHot = feelsLike > 35
//        let isHighUVIndex = uvIndex > 6.0
//        
//        // 위험 평가
//        if isHighRainProbability || isHighRainVolume || isHighSnowVolume || isHighWind || isTooCold || isTooHot || isHighUVIndex {
//            return (.danger, createDangerCoach(
//                rainProbability: isHighRainProbability, rainVolume: isHighRainVolume,
//                snowVolume: isHighSnowVolume, cold: isTooCold, hot: isTooHot,
//                wind: isHighWind, uvIndex: isHighUVIndex,
//                feelsLike: feelsLike, windSpeed: windSpeed, uvValue: uvIndex
//            ))
//        }
//        
//        // 경고 조건 확인
//        if feelsLike < 10 || feelsLike > 30 || humidity > 80 || rainVolume > 1.0 || snowVolume > 1.0 || uvIndex > 5.0 {
//            return (.warning, createWarningCoach(
//                cold: feelsLike < 10, hot: feelsLike > 30, humid: humidity > 80,
//                rainVolume: rainVolume > 1.0, snowVolume: snowVolume > 1.0,
//                uvIndex: uvIndex > 5.0, feelsLike: feelsLike, humidity: humidity
//            ))
//        }
//        
//        // 좋은 날씨 평가
//        return (.good, createGoodCoach(feelsLike: feelsLike))
//    }
    
    static func evaluate(current: WeatherData) -> (grade: RunningGrade, coach: RunningCoach) {
        // 데이터 변환
        let feelsLike = Double(current.apparentTemperature.replacingOccurrences(of: "°C", with: "")) ?? 0
        let humidity = Double(current.humidity.replacingOccurrences(of: "%", with: "")) ?? 0
        let windSpeed = Double(current.windSpeed.components(separatedBy: " ").first ?? "") ?? 0
        let precipitationProbability = Double(current.precipitationProbability.replacingOccurrences(of: "%", with: "")) ?? 0
        _ = Double(current.temperature.replacingOccurrences(of: " mm", with: "")) ?? 0
        let snowVolume = Double(current.temperature.replacingOccurrences(of: " mm", with: "")) ?? 0
        let uvIndex = Double(current.conditionDescription.replacingOccurrences(of: " UV", with: "")) ?? 0
        
        
    func determineSeason() -> Season {
            let currentMonth = Calendar.current.component(.month, from: Date())
            
            switch currentMonth {
            case 3...5:
                return .spring
            case 6...8:
                return .summer
            case 9...11:
                return .autumn
            default:
                return .winter
            }
        }
        
        let season = determineSeason()  // 계절 판별

        // 계절에 따른 평가 호출
        switch season {
        case .spring:
            return evaluateForSpring(feelsLike, humidity, windSpeed, precipitationProbability)
        case .summer:
            return evaluateForSummer(feelsLike, humidity, uvIndex, windSpeed)
        case .autumn:
            return evaluateForAutumn(feelsLike, humidity, windSpeed, precipitationProbability)
        case .winter:
            return evaluateForWinter(feelsLike, snowVolume, windSpeed)
        }
    }

    // 봄 평가
    private static func evaluateForSpring(_ feelsLike: Double, _ humidity: Double, _ windSpeed: Double, _ precipitationProbability: Double) -> (RunningGrade, RunningCoach) {
        let isTooCold = feelsLike < 8
        let isTooHot = feelsLike > 25
        let isRainy = precipitationProbability > 70
        let isWindy = windSpeed > 12.0

        if isRainy || isWindy || isTooCold || isTooHot {
            return (.danger, createDangerCoach(rainProbability: isRainy, rainVolume: false, snowVolume: false, cold: isTooCold, hot: isTooHot, wind: isWindy, uvIndex: false, feelsLike: feelsLike, windSpeed: windSpeed, uvValue: 0))
        } else if feelsLike < 12 || humidity > 75 {
            return (.warning, createWarningCoach(cold: feelsLike < 12, hot: feelsLike > 22, humid: humidity > 75, rainVolume: false, snowVolume: false, uvIndex: false, feelsLike: feelsLike, humidity: humidity))
        } else {
            return (.good, createGoodCoach(feelsLike: feelsLike))
        }
    }

    // 여름 평가
    private static func evaluateForSummer(_ feelsLike: Double, _ humidity: Double, _ uvIndex: Double, _ windSpeed: Double) -> (RunningGrade, RunningCoach) {
        let isTooHot = feelsLike > 33
        let isHumid = humidity > 85
        let isHighUV = uvIndex > 8

        if isTooHot || isHumid || isHighUV {
            return (.danger, createDangerCoach(rainProbability: false, rainVolume: false, snowVolume: false, cold: false, hot: isTooHot, wind: false, uvIndex: isHighUV, feelsLike: feelsLike, windSpeed: windSpeed, uvValue: uvIndex))
        } else if feelsLike > 28 || humidity > 75 {
            return (.warning, createWarningCoach(cold: false, hot: feelsLike > 28

    , humid: humidity > 75, rainVolume: false, snowVolume: false, uvIndex: uvIndex > 6, feelsLike: feelsLike, humidity: humidity))
        } else {
            return (.good, createGoodCoach(feelsLike: feelsLike))
        }
    }

    // 가을 평가
    private static func evaluateForAutumn(_ feelsLike: Double, _ humidity: Double, _ windSpeed: Double, _ precipitationProbability: Double) -> (RunningGrade, RunningCoach) {
        let isWindy = windSpeed > 15
        let isRainy = precipitationProbability > 60
        let isCold = feelsLike < 10

        if isWindy || isRainy || isCold {
            return (.danger, createDangerCoach(rainProbability: isRainy, rainVolume: false, snowVolume: false, cold: isCold, hot: false, wind: isWindy, uvIndex: false, feelsLike: feelsLike, windSpeed: windSpeed, uvValue: 0))
        } else if feelsLike < 15 || humidity > 70 {
            return (.warning, createWarningCoach(cold: feelsLike < 15, hot: false, humid: humidity > 70, rainVolume: false, snowVolume: false, uvIndex: false, feelsLike: feelsLike, humidity: humidity))
        } else {
            return (.good, createGoodCoach(feelsLike: feelsLike))
        }
    }

    // 겨울 평가
    private static func evaluateForWinter(_ feelsLike: Double, _ snowVolume: Double, _ windSpeed: Double) -> (RunningGrade, RunningCoach) {
        let isSnowy = snowVolume > 3
        let isCold = feelsLike < 0
        let isIcyWind = windSpeed > 20

        if isSnowy || isCold || isIcyWind {
            return (.danger, createDangerCoach(rainProbability: false, rainVolume: false, snowVolume: isSnowy, cold: isCold, hot: false, wind: isIcyWind, uvIndex: false, feelsLike: feelsLike, windSpeed: windSpeed, uvValue: 0))
        } else if feelsLike < 5 || snowVolume > 1 {
            return (.warning, createWarningCoach(cold: feelsLike < 5, hot: false, humid: false, rainVolume: false, snowVolume: snowVolume > 1, uvIndex: false, feelsLike: feelsLike, humidity: 0))
        } else {
            return (.good, createGoodCoach(feelsLike: feelsLike))
        }
    }
    
    private static func createDangerCoach(
        rainProbability: Bool, rainVolume: Bool, snowVolume: Bool, cold: Bool, hot: Bool, wind: Bool, uvIndex: Bool,
        feelsLike: Double, windSpeed: Double, uvValue: Double
    ) -> RunningCoach {
        var comment = "현재 날씨가 러닝하기에 적합하지 않습니다. 부상 위험이 있으므로 실내에서 운동하는 것이 좋습니다."
        var gear = "날씨에 맞는 러닝 장비를 준비하세요."
        var shoes = "미끄럼 방지 기능이 있는 러닝화나 날씨에 적합한 신발"
        var alternative = "러닝 대신 실내에서 크로스 트레이닝이나 근력 운동을 추천합니다."
        
        var simpleFeedback = "오늘은 실내에서 운동하는 게 좋겠어요!"

        // 비 올 가능성
        if rainProbability {
            comment = """
            비가 올 가능성이 높습니다. 젖은 노면은 미끄럽고, 체온이 떨어질 위험이 있습니다.  
            비를 맞으며 달리면 감기나 저체온증의 위험도 있으니 주의하세요.
            """
            gear = """
            - 방수 재킷: 비를 막아주면서도 통기성이 좋은 제품 추천.
            - 방수 캡 및 장갑: 비에 젖는 것을 방지하고 체온을 유지합니다.
            """
            shoes = """
            - GORE-TEX 러닝화: 비로부터 발을 보호하고 젖지 않도록 합니다.
            - 접지력 좋은 러닝화: 미끄러운 길에서도 안정감 있게 달릴 수 있도록 합니다.
            """
            alternative = """
            비 오는 날에는 트레드밀에서 인터벌 러닝을 하거나, 하체와 코어를 강화하는 웨이트 트레이닝을 추천합니다.
            """
            simpleFeedback = "비 오는 날에는 트레드밀과 스쿼트가 정답입니다!"

        // 강수량이 많을 때
        } else if rainVolume {
            comment = """
            많은 비가 내리고 있어 시야 확보가 어렵고 노면이 미끄럽습니다.  
            장시간 외부에서 달리는 것은 피하는 것이 좋습니다.
            """
            gear = """
            - 완전 방수 재킷: 폭우에도 몸을 보호할 수 있는 재킷이 필요합니다.
            - 방수 팬츠 및 신발 커버: 하체와 발이 젖지 않도록 보호합니다.
            """
            shoes = """
            - 방수 러닝화: 발을 비로부터 보호하고 젖지 않게 합니다.
            """
            alternative = """
            폭우엔 실내에서 루틴을 바꿔보세요.  
            플랭크, 스쿼트, 런지와 같은 하체 운동이 러닝에 큰 도움이 됩니다.
            """
            simpleFeedback = "폭우엔 실내에서 하체 강화 루틴으로 달리기 준비하세요."

        // 적설량이 많은 경우
        } else if snowVolume {
            comment = """
            눈이 많이 쌓여 있어 러닝 중 미끄러질 위험이 있습니다.  
            눈길에서의 러닝은 발목 부상과 무릎에 부담을 줄 수 있습니다.
            """
            gear = """
            - 방수 및 방한 재킷: 눈과 추위로부터 몸을 보호합니다.
            - 넥워머 및 방한 장갑: 보온 유지 필수!
            - 러닝 타이츠: 하체 보온 강화.
            """
            shoes = """
            - 스터드 러닝화: 미끄러운 눈길에서 안전하게 달릴 수 있도록 돕습니다.
            - GORE-TEX 방수 러닝화: 눈이 발에 스며드는 것을 막아줍니다.
            """
            alternative = """
            눈길이 위험할 땐 실내에서 러너의 힘을 키울 시간입니다.  
            레그 프레스, 데드리프트, 코어 운동으로 러닝 자세를 강화하세요.
            """
            simpleFeedback = "눈 오는 날은 하체와 코어 근력 강화의 날입니다!"

        // 강추위일 경우
        } else if cold {
            comment = """
            체감온도가 \(feelsLike)°C로 매우 낮습니다.  
            추운 날에는 근육이 경직되기 쉽고, 워밍업 없이 달리면 부상 위험이 큽니다.  
            러닝 전에 충분히 몸을 데우고 장비를 잘 챙기세요.
            """
            gear = """
            - 방풍 재킷: 바람을 차단하고 보온 기능이 뛰어난 제품 추천.
            - 기모 장갑 및 모자: 추위에 직접 노출되는 부분을 보호하세요.
            - 러닝 타이츠: 하체 보온 강화.
            """
            shoes = """
            - GORE-TEX 러닝화: 발이 얼지 않도록 방수 및 방한 기능을 제공합니다.
            """
            alternative = """
            추운 날은 실내에서 전신 근력 운동으로 달리기에 필요한 힘을 길러보세요.  
            버피, 마운틴 클라이머, 러시안 트위스트 등 추천합니다.
            """
            simpleFeedback = "추운 날에는 전신 강화 루틴으로!"

        // 폭염일 경우
        } else if hot {
            comment = """
            현재 체감온도가 \(feelsLike)°C로 매우 높습니다.  
            더운 날에는 열사병 위험이 있으며, 탈수가 빠르게 진행될 수 있습니다.  
            자주 수분을 섭취하고 서늘한 시간대에 달리세요.
            """
            gear = """
            - 통기성 좋은 반팔 러닝복: 땀 배출이 잘 되는 제품을 고르세요.
            - 선캡 및 선글라스: 직사광선을 피할 수 있도록 준비하세요.
            - 물병 또는 하이드레이션 팩: 수분 보충을 자주 해야 합니다.
            """
            shoes = """
            - 메쉬 러닝화: 발의 열기를 효과적으로 배출할 수 있는 제품이 필요합니다.
            """
            alternative = """
            더운 날엔 실내에서 러닝을 보조하는 필라테스, 요가, 혹은 상체 근력 운동을 추천합니다.
            """
            simpleFeedback = "더운 날은 요가와 스트레칭으로 몸을 풀어주세요."

        // 자외선 지수 높은 경우
        } else if uvIndex {
            comment = """
            자외선 지수가 \(uvValue)로 매우 높습니다.  
            자외선이 강한 날에는 피부가 쉽게 손상될 수 있으며, 열사병 위험도 있습니다.
            """
            gear = """
            - 자외선 차단 모자 및 선글라스: 피부와 눈을 보호하세요.
            - SPF 50+ 선크림: 러닝 전에 필수로 바르세요.
            """
            shoes = """
            - 밝은 색상의 러닝화: 열 흡수를 줄여 발을 시원하게 유지합니다.
            """
            alternative = """
            자외선이 강한 날은 실내에서 HIIT(고강도 인터벌 트레이닝)나 스피드 트레이닝을 추천합니다.
            """
            simpleFeedback = "자외선 강할 땐 HIIT로 짧고 강하게 운동하세요!"
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
        var comment = "날씨가 다소 불편할 수 있지만, 적절한 준비를 통해 안전하게 러닝할 수 있습니다."
        var gear = "날씨에 맞는 러닝 의류와 장비를 준비하세요."
        var shoes = "쿠셔닝과 접지력이 좋은 러닝화"
        var alternative = "날씨와 환경을 고려해 적절한 시간대에 러닝을 계획하세요."
        var simpleFeedback = "기본 수칙: 천천히, 짧게, 무리하지 않게 시작하세요!"

        if cold {
            comment = """
            현재 체감온도가 \(feelsLike)°C로 다소 춥습니다. 워밍업을 충분히 하고 러닝 중 체온이 떨어지지 않도록 유의하세요.
            특히 손, 귀, 발 등 노출 부위를 보호하는 것이 중요합니다.
            """
            gear = """
            - 보온 기능이 뛰어난 러닝 재킷: 바람 차단 및 체온 유지.
            - 방한 장갑 및 귀마개: 추위로부터 보호.
            - 러닝 타이츠: 하체 보온 강화.
            """
            shoes = """
            - GORE-TEX 소재 러닝화: 방수 및 방풍 기능으로 눈과 비로부터 발을 보호합니다.
            """
            alternative = "낮 시간대 러닝을 추천하거나, 실내에서 트레드밀 러닝을 고려하세요."
            simpleFeedback = "추운 날씨! 워밍업 후 짧게 달리세요."

        } else if hot {
            comment = """
            현재 체감온도가 \(feelsLike)°C로 덥습니다. 탈수 및 열사병 위험이 있으므로 수분 섭취에 신경 쓰세요.
            러닝 중간에도 자주 수분을 섭취하고, 햇볕을 피하는 것이 중요합니다.
            """
            gear = """
            - 통기성이 뛰어난 반팔/반바지 러닝복: 열 배출 용이.
            - UV 차단 모자 및 선글라스: 직사광선으로부터 보호.
            - 수분 백팩: 장거리 러닝 시 수분 보충에 필수.
            """
            shoes = """
            - 통기성이 좋은 메쉬 러닝화: 발의 과열 방지.
            - 밝은 색상의 러닝화: 태양광 흡수를 최소화.
            """
            alternative = "햇볕이 약한 이른 아침이나 저녁에 러닝하세요."
            simpleFeedback = "더운 날씨! 수분을 자주 섭취하고 무리하지 마세요."

        } else if humid {
            comment = """
            현재 습도가 \(humidity)%로 높습니다. 땀 배출이 어렵고 체온이 상승하기 쉬우므로 속도를 조절하세요.
            """
            gear = """
            - 흡습성과 통기성이 뛰어난 러닝복: 땀을 빠르게 흡수 및 배출.
            - 헤드밴드 및 손목밴드: 땀으로 인해 불편하지 않도록 준비하세요.
            """
            shoes = """
            - 통기성이 좋은 러닝화: 발이 답답하지 않도록 쾌적함 유지.
            - 흡습 인솔(깔창): 발의 땀을 흡수해 편안함 유지.
            """
            alternative = "습도가 낮은 시간대(아침 또는 저녁)에 러닝을 추천하거나 실내에서 운동하세요."
            simpleFeedback = "습한 날씨! 천천히 달리고 수분을 자주 섭취하세요."

        } else if rainVolume {
            comment = """
            현재 비가 내리고 있습니다. 노면이 미끄러울 수 있으므로 러닝 속도를 조절하고 조심하세요.
            """
            gear = """
            - GORE-TEX 방수 러닝 재킷: 비를 막으면서 통기성이 우수해 땀 배출이 원활합니다.
            - 방수 장갑 및 모자: 젖는 것을 방지하고 체온을 유지합니다.
            """
            shoes = """
            - GORE-TEX 소재 러닝화: 비로부터 발을 보호하고 방수 기능을 제공합니다.
            - 접지력 강화 러닝화: 미끄러운 길에서도 안정적인 러닝 가능.
            """
            alternative = "비가 멈춘 후 러닝을 추천하거나 실내에서 트레드밀을 이용하세요."
            simpleFeedback = "비 오는 날! GORE-TEX 러닝화를 착용하세요."

        } else if snowVolume {
            comment = """
            현재 눈이 내리고 있습니다. 눈길은 미끄러울 수 있으니 주의하고 러닝 속도를 줄이세요.
            """
            gear = """
            - 방수 및 보온 러닝 재킷: 눈으로부터 체온을 보호합니다.
            - 넥워머 및 방수 팬츠: 하체 보온 필수.
            - 러닝 타이츠: 하체 보온 강화.
            """
            shoes = """
            - GORE-TEX 소재 러닝화: 눈으로부터 발을 보호하고 방수 및 방한 기능을 제공합니다.
            - 스터드 러닝화: 눈길에서 미끄러짐을 방지합니다.
            """
            alternative = "눈이 녹거나 제설된 길에서 러닝하세요. 또는 실내에서 운동을 추천합니다."
            simpleFeedback = "눈길 주의! GORE-TEX 러닝화와 스터드 러닝화를 착용하세요."

        } else if uvIndex {
            comment = """
            자외선 지수가 높습니다. 피부 손상 및 열사병 예방을 위해 자외선 차단제를 사용하세요.
            """
            gear = """
            - UV 차단 모자 및 선글라스: 눈과 피부 보호.
            - SPF 50+ 자외선 차단제: 햇볕으로부터 피부 보호.
            """
            shoes = """
            - 밝은 색상의 러닝화: 열 흡수를 줄여 발의 온도를 낮춥니다.
            - 통기성 좋은 러닝화: 발의 과열을 방지합니다.
            """
            alternative = "자외선이 낮은 시간대(이른 아침, 저녁)에 러닝하세요."
            simpleFeedback = "자외선 강함! 모자와 선크림 필수입니다."

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
        // 기본 메시지
        var simpleFeedback = "오늘은 러닝하기 좋은 날씨네요! 가볍게 뛰어보세요."
        var comment = "러닝하기에 쾌적한 날씨입니다. 무리하지 말고 페이스를 즐기세요."
        var alternative = "러닝하기 딱 좋은 날입니다. 공원이나 트랙에서 즐겨보세요."
        var gear = """
        - 땀을 잘 배출하는 러닝복: 통기성이 좋은 소재로 쾌적함 유지.
        - 러닝 캡: 햇볕을 가리고 체온을 유지합니다.
        """

        // 온도에 따른 조건 분기
        switch feelsLike {
        case ..<15:
            comment = """
            상쾌한 날씨입니다! 약간 쌀쌀하지만 근육 온도 유지에 좋습니다.  
            장거리 러닝이나 템포 러닝에 적합합니다. 페이스 조절에 집중해 보세요.
            """
            alternative = "러닝 초반에는 조금 쌀쌀할 수 있으니, 가벼운 레이어링을 추천합니다."
            gear = """
            - 가벼운 긴팔 러닝 셔츠: 체온 조절을 도와줍니다.
            - 바람막이 재킷: 달리다 더우면 쉽게 벗을 수 있도록 가벼운 소재 추천.
            - 러닝 캡: 체온 손실을 줄이고 햇볕을 차단합니다.
            """
            simpleFeedback = "선선한 날씨! 긴팔 러닝복으로 부담 없이 달려보세요."

        case 15...25:
            comment = """
            이보다 더 좋은 날씨는 없습니다! 기온이 적당해 러닝 퍼포먼스를 끌어올릴 수 있습니다.  
            다양한 인터벌 트레이닝이나 페이스 변화를 시도하기에 좋은 환경입니다.
            """
            alternative = "공원이나 트랙에서 페이스 러닝이나 인터벌 훈련을 추천합니다."
            gear = """
            - 반팔 러닝 셔츠: 땀을 빠르게 배출하고 쾌적함을 유지합니다.
            - 경량 러닝 캡: 햇볕을 막고 통기성이 뛰어난 제품을 추천합니다.
            - GPS 러닝 워치: 거리와 페이스를 체크해보세요.
            """
            simpleFeedback = "러닝하기 딱 좋은 날! 반팔 셔츠로 시원하게 뛰세요."

        default:
            comment = """
            덥고 습한 날씨입니다. 체온이 빠르게 올라가니 수분 보충에 신경 쓰세요.  
            긴 러닝보다는 짧고 가볍게 달리는 것을 추천합니다.
            """
            alternative = "러닝은 해가 질 무렵이나 아침 이른 시간대가 좋습니다."
            gear = """
            - 가벼운 반팔/반바지 러닝복: 통기성이 좋고 땀이 빠르게 마르는 제품 추천.
            - 밝은 색상의 러닝 캡: 열 흡수를 줄여줍니다.
            - 하이드레이션 벨트: 러닝 중에도 간편하게 물을 섭취할 수 있습니다.
            """
            simpleFeedback = "날씨가 더우니 물 자주 마시면서 짧게 뛰세요!"
        }

        // 공통 러닝화 추천
        let shoes = """
        - 쿠셔닝이 좋은 러닝화: 장거리 러닝에 발 피로를 줄여줍니다.
        - 통기성이 뛰어난 러닝화: 발을 시원하게 유지해 장거리에도 쾌적합니다.
        """

        // RunningCoach 객체 생성 및 반환
        return RunningCoach(
            simpleFeedback: simpleFeedback,
            comment: comment,
            alternative: alternative,
            gear: gear,
            shoes: shoes
        )
    }
}
