//
//  AICoachView.swift
//  running-check
//
//  Created by mason on 1/21/25.
//

import SwiftUI

struct AICoachView: View {
    @EnvironmentObject private var weatherKitViewModel: WeatherKitViewModel
    @StateObject private var viewModel = ChatViewModel()
    
    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .ignoresSafeArea()
            
            if viewModel.isLoading {
                LoadingView(message: "AI 러닝코치가 분석중...✨")
                    .transition(.opacity) // 부드러운 전환 효과 추가
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 35) {
                            // ChatGPT 응답을 순서대로 출력
                            ForEach(viewModel.chatResponse.keys.sorted { lhs, rhs in
                                let lhsId = viewModel.chatResponse[lhs]?["id"] as? Int ?? 0
                                let rhsId = viewModel.chatResponse[rhs]?["id"] as? Int ?? 0
                                return lhsId < rhsId
                            }, id: \.self) { key in
                                if let entry = viewModel.chatResponse[key],
                                   let description = entry["description"] as? String {
                                    AICoachRowView(key: key, description: description)
                                }
                            }
                        }
                    .padding()
                }
                .navigationTitle("AI 러닝코칭")
                .navigationBarTitleDisplayMode(.large)
                
            }
        }
        .onAppear {
            Task {
                if let weatherData = weatherKitViewModel.weatherData {
                    // formattedWeatherMessage를 viewModel.userMessage에 설정
//                    print("보메로5 울프 그레이", formattedWeatherMessage(from: weatherData))
                    viewModel.userMessage = formattedWeatherMessage(from: weatherData)
                    await viewModel.sendMessage()
                }
            }
        }
    }
    
    /// 템플릿화된 메시지 생성 함수
    private func formattedWeatherMessage(from weatherData: WeatherData) -> String {
        """
        현재 계절: \(weatherData.season)
        대기질: \(weatherData.airQualityCategory)
        대기 오염 물질: \(weatherData.pollutants)
        현재 날씨 상태: \(weatherData.conditionDescription) (\(weatherData.conditionSymbolName))
        온도: \(weatherData.temperature) (체감 온도: \(weatherData.apparentTemperature))
        습도: \(weatherData.humidity)
        풍속: \(weatherData.windSpeed)
        강수 확률: \(weatherData.precipitationProbability)
        최고 기온: \(weatherData.maxTemperature), 최저 기온: \(weatherData.minTemperature)
        자외선 지수: \(weatherData.uvIndex)
        적설량: \(weatherData.snowfallAmount)
        
        메타데이터:
        \(weatherData.conditionMetaData)
        
        러닝 괜찮을까요?
        """
    }
    
    private func filteredChatResponse(_ response: String) -> String {
        // 제거할 특수 문자의 집합
        let charactersToRemove = CharacterSet(charactersIn: "#-*")
        
        // 필터링하여 특수 문자를 제거
        return response.components(separatedBy: charactersToRemove).joined()
    }
}

#Preview {
    AICoachView()
        .environmentObject(WeatherKitViewModel())
}
