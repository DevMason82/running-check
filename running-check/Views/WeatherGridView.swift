//
//  WeatherGridView.swift
//  running-check
//
//  Created by mason on 11/26/24.
//

import SwiftUI
import CoreLocation

struct WeatherGridView: View {
    let weather: WeatherData
    
    private let columns = [
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack {
            Text("날씨 정보")
                .font(.title)
                .foregroundColor(Color("CardFontColor"))
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.bottom, 15)
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: columns, spacing: 10) {
                    WeatherCard(title: "대기질", value: weather.airQualityCategory)
                    WeatherCard(title: "최고 / 최저", value: "\(weather.maxTemperature) / \(weather.minTemperature)")
                    WeatherCard(title: "풍속", value: weather.windSpeed)
                    WeatherCard(title: "습도", value: weather.humidity)
                    WeatherCard(title: "강수량", value: weather.precipitationProbability)
                    //            WeatherCard(title: "적설량", value: weather.snowfallAmount)
                    WeatherCard(title: "자외선", value: weather.uvIndex)
                }
                .padding(.horizontal, 20)
            }
            
            Spacer()
            
            // Apple Weather Attribution
            HStack {
                Text("날씨 데이터 제공:  Weather")
                    .font(.footnote)
                    .foregroundColor(Color("CardFontColor"))
                
                Spacer()
                
                Link("자세한 정보 보기", destination: URL(string: "https://weatherkit.apple.com/legal-attribution.html")!)
                    .font(.footnote)
                    .foregroundColor(Color("CardFontColor"))
                    .padding(.top, 1)
            }
            .padding(.horizontal, 24)
            //                        .background(Color.black.opacity(0.1))
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        
    }
}

#Preview {
    WeatherGridView(
        weather: WeatherData(
            temperature: "25°C",
            apparentTemperature: "27°C",
            conditionDescription: "Clear",
            conditionSymbolName: "sun.max.fill",
            conditionMetaData: WeatherMetaData(
                date: Date(),
                expirationDate: Date().addingTimeInterval(3600),
                location: CLLocation(latitude: 37.7749, longitude: -122.4194)
            ),
            humidity: "60%",
            windSpeed: "5 m/s",
            precipitationProbability: "10%",
            maxTemperature: "30°C",
            minTemperature: "20°C",
            uvIndex: "5",
            snowfallAmount: "0 mm",
            airQualityIndex: "",
            airQualityCategory: "",
            season: "겨울",
            pollutants: [
                "CO": 201.94,
                "NO": 0.02,
                "NO₂": 0.77,
                "O₃": 95.08,
                "SO₂": 0.16,
                "PM2.5": 15.35,
                "PM10": 19.11,
                "NH₃": 0.56
            ]
            
        )
    )
}
