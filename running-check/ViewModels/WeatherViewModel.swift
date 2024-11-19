//
//  WeatherViewModel.swift
//  running-check
//
//  Created by mason on 11/18/24.
//

import Foundation
import Combine

enum Season {
    case spring, summer, autumn, winter
    
    // 계절별 온도 기준
    static func getSeason(from temperature: Double) -> Season {
        switch temperature {
        case 15...25: return .spring
        case 26...35: return .summer
        case 10..<15: return .autumn
        default: return .winter
        }
    }
}

// 러닝 등급
enum RunningGrade: String {
    case good = "Good"
    case warning = "Warning"
    case danger = "Danger"
}

// 러닝 코치 메세지
struct RunningCoach {
    let comment: String
    let gear: String
    let shoes: String
}

// 러닝 기준 평가
class RunningEvaluator {
    static func evaluate(current: CurrentWeather) -> (grade: RunningGrade, coach: RunningCoach) {
        // 날씨 조건
        let rainVolume = current.rain?.oneHour ?? 0
        let snowVolume = current.snow?.oneHour ?? 0
        let windSpeed = current.wind_speed
        let uvIndex = current.uvi
        let feelsLike = current.feels_like
        let humidity = current.humidity
        
        // 강수량, 적설량 체크
        let isRain = rainVolume > 2.0
        let isSnow = snowVolume > 2.0
        
        // 바람, 자외선, 온도 체크
        let isHighWind = windSpeed > 10.0
        let isUVHigh = uvIndex > 6.0
        let isTooCold = feelsLike < 5
        let isTooHot = feelsLike > 35
        
        // 위험 평가
        if isRain || isSnow || isHighWind || isUVHigh || isTooCold || isTooHot {
            var dangerMessage = "러닝을 삼가는 것이 좋습니다. 안전이 최우선입니다."
            var dangerGear = "방수 재킷, 방풍 장갑"
            let dangerShoes = "미끄럼 방지 기능이 있는 러닝화"
            
            if isRain {
                dangerMessage = """
                강수량이 \(rainVolume)mm입니다. 젖은 노면에서 미끄러질 위험이 높습니다. 
                강수량 2mm 이상이면 접지력이 감소하므로 실내 러닝을 권장합니다.
                """
                dangerGear = "방수 러닝 재킷"
            } else if isSnow {
                dangerMessage = """
                적설량이 \(snowVolume)mm입니다. 눈길에서의 러닝은 부상을 초래할 수 있습니다. 
                낮은 온도에서 근육이 경직될 가능성이 있으므로 충분한 워밍업이 필수적입니다.
                """
                dangerGear = "보온성이 높은 러닝 의류"
            } else if isTooCold {
                dangerMessage = """
                체감온도가 \(feelsLike)°C로 너무 낮습니다. 근육 경직과 저체온증의 위험이 있습니다.
                러닝 전에 철저한 워밍업과 보온 장비 착용을 권장합니다.
                """
                dangerGear = "방한용 러닝 재킷과 장갑"
            } else if isTooHot {
                dangerMessage = """
                체감온도가 \(feelsLike)°C로 너무 높습니다. 탈수와 열사병 위험이 있으므로 주의가 필요합니다.
                고온 환경에서는 러닝 속도를 줄이고 수분 섭취를 늘리세요.
                """
                dangerGear = "통기성이 우수한 경량 러닝 의류"
            } else if isHighWind {
                dangerMessage = """
                풍속이 \(windSpeed)m/s입니다. 강한 바람은 체온을 빠르게 빼앗아 저체온증을 유발할 수 있습니다.
                방풍 기능이 있는 의류를 착용하세요.
                """
                dangerGear = "방풍 재킷"
            } else if isUVHigh {
                dangerMessage = """
                자외선 지수가 \(uvIndex)로 높습니다. 피부 보호를 위해 자외선 차단제를 사용하고, 
                UV 차단 기능이 있는 러닝 모자를 착용하세요.
                """
                dangerGear = "UV 차단 모자와 선글라스"
            }
            
            return (.danger, RunningCoach(
                comment: dangerMessage,
                gear: dangerGear,
                shoes: dangerShoes
            ))
        }
        
        // 경고 평가
        if feelsLike < 10 || feelsLike > 30 || humidity > 80 {
            var warningMessage = "날씨가 적당하지 않을 수 있습니다. 준비를 철저히 하세요."
            var warningGear = "가벼운 방한복 또는 통기성 좋은 옷"
            let warningShoes = "접지력이 좋은 러닝화"
            
            if feelsLike < 10 {
                warningMessage = """
                체감온도가 \(feelsLike)°C입니다. 추운 날씨는 근육 경직을 초래할 수 있습니다. 
                러닝 전에 충분히 몸을 풀고, 러닝 중간에는 체온 유지를 위한 옷을 착용하세요.
                """
                warningGear = "가벼운 방한복과 러닝 장갑"
            } else if feelsLike > 30 {
                warningMessage = """
                체감온도가 \(feelsLike)°C입니다. 더운 날씨는 탈수와 열사병 위험을 증가시킵니다.
                수분 섭취를 충분히 하고 햇빛을 피하는 경로를 선택하세요.
                """
                warningGear = "통기성 좋은 옷과 모자"
            } else if humidity > 80 {
                warningMessage = """
                습도가 \(humidity)%로 높습니다. 높은 습도는 땀이 증발하지 않아 체온 조절이 어려울 수 있습니다. 
                물을 충분히 준비하고, 천천히 페이스를 조절하세요.
                """
                warningGear = "흡습성이 좋은 옷"
            }
            
            return (.warning, RunningCoach(
                comment: warningMessage,
                gear: warningGear,
                shoes: warningShoes
            ))
        }
        
        // 좋은 날씨 평가
        return (.good, RunningCoach(
            comment: """
            날씨가 이상적입니다! 현재 체감온도는 \(feelsLike)°C로 러닝하기에 최적의 조건입니다. 
            이온 음료를 준비하여 러닝 중 수분 공급을 유지하세요.
            """,
            gear: "가벼운 러닝복과 모자",
            shoes: "쿠션감이 좋은 러닝화"
        ))
    }
}

class WeatherViewModel: ObservableObject {
    @Published var runningGrade: RunningGrade = .good
    @Published var coachMessage: RunningCoach = RunningCoach(comment: "", gear: "", shoes: "")
    @Published var weatherIcon: String = ""
    @Published var weatherMain: String = ""
    @Published var currentTemp: String = ""
    @Published var feelsLike: String = ""
    @Published var rainVolume: String = "0 mm"
    @Published var snowVolume: String = "0 mm"
    @Published var windSpeed: String = ""
    @Published var uvIndex: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    func fetchWeather(lat: Double, lon: Double) {
        let apiKey = "acf2a01baada6c80f15aeeaed1728d39" // OpenWeather API 키를 입력하세요.
        let url = URL(string: "https://api.openweathermap.org/data/3.0/onecall?lat=\(lat)&lon=\(lon)&exclude=minutely, alerts&units=metric&appid=\(apiKey)")!
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: OneCallResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Failed to fetch weather: \(error.localizedDescription)")
                }
            }, receiveValue: { response in
                self.updateRunningEvaluation(from: response.current)
            })
            .store(in: &cancellables)
    }
    
    private func updateRunningEvaluation(from current: CurrentWeather) {
        let evaluation = RunningEvaluator.evaluate(current: current)
        self.runningGrade = evaluation.grade
        self.coachMessage = evaluation.coach
        self.currentTemp = "\(Int(current.temp))°C"
        self.feelsLike = "\(Int(current.feels_like))°C"
        self.rainVolume = "\(current.rain?.oneHour ?? 0) mm"
        self.snowVolume = "\(current.snow?.oneHour ?? 0) mm"
        self.windSpeed = "\(current.wind_speed) m/s"
        self.uvIndex = "\(current.uvi)"
        
        if let weather = current.weather.first {
            self.weatherIcon = weather.icon
            self.weatherMain = weather.main
        }
    }
}
