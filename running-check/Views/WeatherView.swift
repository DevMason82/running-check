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
                    //                    VStack(spacing: 10) {
                    VStack {
                        WeatherHeaderView(
                            weather: weather,
                            locationName: locationManagerNew.locality ?? "Loading..."
                        )
                    }
                    .padding(.vertical, 20)
                    
                    
                    RunningGradeView(
                        grade: weatherKitViewModel.runningGrade ?? .good
                    )
                    
                    VStack {
                        WeatherSummaryView(weather: weather)
                    }
                    .padding(.bottom, 15)
                    
                    
                    
//                    Text("업데이트 시간: \(weather.conditionMetaData.date.formatted(.dateTime))")
//                        .frame(maxWidth: .infinity, alignment: .trailing)
//                        .padding(.horizontal)
                    
//                    // 업데이트 버튼
//                                            Button(action: {
//                                                weatherKitViewModel.updateWeatherData() // 데이터 갱신
//                                            }) {
//                                                Text("업데이트")
//                                                    .font(.headline)
//                                                    .foregroundColor(.white)
//                                                    .padding()
//                                                    .frame(maxWidth: .infinity)
//                                                    .background(Color.blue)
//                                                    .cornerRadius(10)
//                                            }
//                                            .padding(.top, 10)
                    
                    RunningCoachView(
                        coach: weatherKitViewModel.runningCoach
                    )
                    
                    Divider().padding(.vertical, 10)
                    
                    WeatherGridView(weather: weather)
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
        
//        .onAppear {
//            Task {
//                do {
//                    let location = try await weatherKitViewModel.fetchUserLocation() // 위치 가져오기
//                    await weatherKitViewModel.fetchWeatherAndEvaluateRunning(location: location) // 날씨 데이터 가져오기
//                } catch {
//                    weatherKitViewModel.errorMessage = weatherKitViewModel.translateError(error) // 에러 처리
//                }
//            }
//        }
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
