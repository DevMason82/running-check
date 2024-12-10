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
        VStack(spacing: 0) {
            Text("날씨 정보")
                .font(.body)
                .foregroundColor(Color("CardFontColor"))
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.bottom, 15)
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: columns, spacing: 10) {
                    WeatherCard(title: "최고 / 최저", value: "\(weather.maxTemperature) / \(weather.minTemperature)")
                    WeatherCard(title: "풍속", value: weather.windSpeed)
                    WeatherCard(title: "습도", value: weather.humidity)
                    WeatherCard(title: "강수량", value: weather.precipitationProbability)
                    //            WeatherCard(title: "적설량", value: weather.snowfallAmount)
                    WeatherCard(title: "자외선", value: weather.uvIndex)
                }
                .padding(.horizontal)
            }
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
            snowfallAmount: "0 mm"
        )
    )
}
