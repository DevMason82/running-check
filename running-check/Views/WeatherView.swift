//
//  WeatherView.swift
//  running-check
//
//  Created by mason on 11/18/24.
//

import SwiftUI

struct WeatherView: View {
    @StateObject private var viewModel = WeatherViewModel()

    var body: some View {
        VStack(spacing: 20) {
            TextField("Enter latitude", text: $viewModel.latitude)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.decimalPad)
                .padding()

            TextField("Enter longitude", text: $viewModel.longitude)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.decimalPad)
                .padding()

            Button(action: {
                viewModel.fetchWeather()
            }) {
                Text("Get Weather")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            } else {
                Text(viewModel.weatherDescription)
                    .font(.title)
                    .padding()

                Text(viewModel.currentTemp)
                    .font(.largeTitle)
                    .bold()

                List(viewModel.dailyForecast, id: \.self) { forecast in
                    Text(forecast)
                }
            }

            Spacer()
        }
        .padding()
    }
}

#Preview {
    WeatherView()
}
