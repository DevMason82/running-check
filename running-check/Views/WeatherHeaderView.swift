//
//  WeatherHeaderView.swift
//  running-check
//
//  Created by mason on 11/26/24.
//

import SwiftUI
import CoreLocation

struct WeatherHeaderView: View {
    let weather: WeatherData
    let locationName: String
    
    var body: some View {
        HStack {
            Image(systemName: weather.conditionSymbolName)
                .font(.system(size: 68))
            
            VStack(alignment: .leading) {
                Text(locationName)
                    .font(.largeTitle)
                    .bold()
                Text(weather.conditionDescription)
                    .font(.body)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    WeatherHeaderView(
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
        ),
        locationName: "San Francisco"
    )
}
