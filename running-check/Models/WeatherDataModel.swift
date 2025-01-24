//
//  WeatherDataModel.swift
//  running-check
//
//  Created by mason on 11/25/24.
//

import Foundation
import CoreLocation

struct WeatherMetaData {
    let date: Date
    let expirationDate: Date
    let location: CLLocation
}

struct WeatherData {
    let temperature: String
    let apparentTemperature: String
    let conditionDescription: String
    let conditionSymbolName: String
    let conditionMetaData: WeatherMetaData
    let humidity: String
    let windSpeed: String
    let precipitationProbability: String
    let maxTemperature: String
    let minTemperature: String
    let uvIndex: String
    let snowfallAmount: String
    let airQualityIndex: String
    let airQualityCategory: String
    let season: String
    let pollutants: [String: Double]
}
