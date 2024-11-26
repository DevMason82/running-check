//
//  WeatherView.swift
//  running-check
//
//  Created by mason on 11/18/24.
//

import SwiftUI
import CoreLocation

struct WeatherView: View {
    @StateObject private var weatherKitViewModel = WeatherKitViewModel()
    @StateObject private var locationManagerNew = LocationManagerNew()
    
    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                if let errorMessage = weatherKitViewModel.errorMessage {
                    ErrorView(
                        errorMessage: errorMessage,
                        onSettingsTap: openAppSettings
                    )
                } else if let weather = weatherKitViewModel.weatherData {
                    VStack() {
                        WeatherHeaderView(
                            weather: weather,
                            locationName: locationManagerNew.locality ?? "Loading..."
                        )
                        
                        RunningGradeView(
                            grade: weatherKitViewModel.runningGrade ?? .good
                        )
                        WeatherSummaryView(weather: weather)
                        
                        RunningCoachView(
                            coach: weatherKitViewModel.runningCoach
                        )
                        
                        Divider().padding(.vertical, 10)
                        
                        WeatherGridView(weather: weather)
                    }
                    .padding(.horizontal)
                } else {
                    LoadingView(message: "Fetching Weather...")
                }
            }
        }
        .onAppear {
            Task {
                await weatherKitViewModel.fetchWeatherAndEvaluateRunning()
            }
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

#Preview {
    WeatherView()
        .environment(\.colorScheme, .dark)
}
