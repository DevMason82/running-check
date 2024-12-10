//
//  WeatherSummaryView.swift
//  running-check
//
//  Created by mason on 11/26/24.
//

import SwiftUI
import CoreLocation

struct WeatherSummaryView: View {
    let weather: WeatherData
    
    var body: some View {
        VStack(alignment: .trailing) {
            Text(weather.temperature)
                .font(.title2)
                .foregroundColor(Color("CardFontColor"))
                .bold()
            Text("체감온도: \(weather.apparentTemperature)")
                .font(.body)
                .foregroundColor(Color("CardFontColor"))
        }
    }
}

#Preview {
    WeatherSummaryView(
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
