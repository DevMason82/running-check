//
//  WeatherView.swift
//  running-check
//
//  Created by mason on 11/18/24.
//

import SwiftUI

struct WeatherView: View {
    @StateObject private var viewModel = WeatherViewModel()
    @StateObject private var locationManager = LocationManager()

    var body: some View {
        ScrollView { // ScrollView로 모든 콘텐츠를 감쌉니다.
            VStack(spacing: 20) {
                if let errorMessage = locationManager.errorMessage {
                    VStack {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()

                        if locationManager.locationStatus == .denied {
                            Button("위치 권한 설정으로 이동") {
                                openAppSettings()
                            }
                            .foregroundColor(.blue)
                            .padding()
                        }
                    }
                } else {
                    VStack {
                        Text("Current Address:")
                            .font(.headline)
                        Text(locationManager.address)
                            .font(.body)
                            .padding()
                            .multilineTextAlignment(.center)
                    }

                    Text("Running Grade: \(viewModel.runningGrade.rawValue)")
                        .font(.title)

                    Text(viewModel.coachMessage.comment)
                        .font(.headline)
                        .padding()
//                        .multilineTextAlignment(.center)
                        .lineLimit(nil)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Recommended Gear: \(viewModel.coachMessage.gear)")
                        Text("Recommended Shoes: \(viewModel.coachMessage.shoes)")
                    }
                    .padding()

                    if let iconURL = URL(string: "https://openweathermap.org/img/wn/\(viewModel.weatherIcon)@2x.png") {
                        AsyncImage(url: iconURL) { image in
                            image.resizable()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 100, height: 100)
                    }

                    Text("Weather: \(viewModel.weatherMain)")
                        .font(.subheadline)

                    // 현재 날씨 정보
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Current Temperature: \(viewModel.currentTemp)")
                        Text("Feels Like: \(viewModel.feelsLike)")
                        Text("Rain Volume: \(viewModel.rainVolume)")
                        Text("Snow Volume: \(viewModel.snowVolume)")
                        Text("Wind Speed: \(viewModel.windSpeed)")
                        Text("UV Index: \(viewModel.uvIndex)")
                    }
                    .font(.body)
                    .padding()

                    Spacer()
                }
            }
            .padding()
        }
        .onAppear {
            if locationManager.latitude != 0.0 && locationManager.longitude != 0.0 {
                viewModel.fetchWeather(lat: locationManager.latitude, lon: locationManager.longitude)
            } else {
                locationManager.checkAndRequestLocationPermission()
            }
        }
        .onChange(of: locationManager.latitude) {
            viewModel.fetchWeather(lat: locationManager.latitude, lon: locationManager.longitude)
        }
    }

    private func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    WeatherView()
}
