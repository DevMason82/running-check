//
//  HealthDataView.swift
//  running-check
//
//  Created by mason on 11/30/24.
//

import SwiftUI

struct HealthDataView: View {
//    @StateObject private var healthViewModel = HealthKitViewModel()
    @EnvironmentObject var healthViewModel: HealthKitViewModel

    
    var body: some View {
        VStack {
            if let errorMessage = healthViewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            } else {
//                Text("Active Calories Burned")
//                    .font(.headline)
//                    .padding(.bottom)
                HStack {
                    
                    Text("\(healthViewModel.runningDistance / 1000, specifier: "%.2f") km")
                                                    .font(.title)
                                                    .bold()
                    Spacer()
                    Text("\(healthViewModel.activeCalories, specifier: "%.2f") kcal")
                        .font(.title)
                        .bold()
                }
            }
        }
        .padding()
        .onAppear {
            Task {
                await healthViewModel.requestAuthorization()
                await healthViewModel.fetchAllHealthDataToday()
            }
        }
    }
}

#Preview {
    HealthDataView()
        .environmentObject(HealthKitViewModel.preview)
}
