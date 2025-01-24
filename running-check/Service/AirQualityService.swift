//
//  AirQualityService.swift
//  running-check
//
//  Created by mason on 1/21/25.
//

import Foundation
import CoreLocation

class AirQualityService {
    private let apiKey = "acf2a01baada6c80f15aeeaed1728d39"
    private let locationManager = LocationManagerNew()
    
//    func fetchAirQuality(for location: CLLocation) async throws -> (index: Int, components: [String: Double]) {
//        let url = URL(string: "https://api.openweathermap.org/data/2.5/air_pollution?lat=\(locationManager.latitude)&lon=\(locationManager.longitude)&appid=\(apiKey)")!
//        
//        let (data, _) = try await URLSession.shared.data(from: url)
//        
//        let response = try JSONDecoder().decode(OpenWeatherAirQualityResponse.self, from: data)
//        let aqi = response.list.first?.main.aqi ?? 0
//        let components = response.list.first?.components ?? [:]
//        
//        return (aqi, components)
//    }
    func fetchAirPollution(for location: CLLocation) async throws -> AirPollutionResponse {
            // 요청 URL 생성
            let urlString = "https://api.openweathermap.org/data/2.5/air_pollution?lat=\(locationManager.latitude)&lon=\(locationManager.longitude)&appid=\(apiKey)"
            guard let url = URL(string: urlString) else {
                throw URLError(.badURL)
            }
            
            // API 호출
            let (data, _) = try await URLSession.shared.data(from: url)
            
            // JSON 디코딩
            let response = try JSONDecoder().decode(AirPollutionResponse.self, from: data)
            return response
        }
}

struct AirPollutionResponse: Decodable {
    struct ListItem: Decodable {
        struct Main: Decodable {
            let aqi: Int
        }
        struct Components: Decodable {
            let co: Double // 일산화탄소 (Carbon Monoxide)
            let no: Double // 일산화질소 (Nitric Oxide)
            let no2: Double // 이산화질소 (Nitrogen Dioxide)
            let o3: Double // 오존 (Ozone)
            let so2: Double // 이산화황 (Sulfur Dioxide)
            let pm2_5: Double // 미세먼지 (PM2.5)
            let pm10: Double // 미세먼지 (PM10)
            let nh3: Double // 암모니아 (Ammonia)

            // 기본값 생성자 추가
            init(co: Double = 0, no: Double = 0, no2: Double = 0, o3: Double = 0, so2: Double = 0, pm2_5: Double = 0, pm10: Double = 0, nh3: Double = 0) {
                self.co = co
                self.no = no
                self.no2 = no2
                self.o3 = o3
                self.so2 = so2
                self.pm2_5 = pm2_5
                self.pm10 = pm10
                self.nh3 = nh3
            }
        }
        let main: Main
        let components: Components
        let dt: Int // 데이터 타임스탬프
    }
    let list: [ListItem]
}
