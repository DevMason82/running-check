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
                
                HStack {
                    VStack {
                        Text("Outdoor Runs Today")
                            .font(.headline)
                        if healthViewModel.outdoorRuns.isEmpty {
                            Text("실외 러닝 정보 없습니다.")
                                .foregroundColor(.gray)
                                .italic()
                        } else {
                            ForEach(healthViewModel.outdoorRuns, id: \.startDate) { run in
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Distance: \(run.distance / 1000, specifier: "%.2f") km")
                                    Text("Pace: \(run.pace / 60, specifier: "%.2f") min/km")
                                    Text("Calories: \(run.calories, specifier: "%.2f") kcal")
                                    Text("Duration: \(formatDuration(run.duration))")
                                }
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    VStack {
                        Text("Indoor Runs Today")
                            .font(.headline)
                        if healthViewModel.indoorRuns.isEmpty {
                            Text("실내 러닝 정보 없습니다.")
                                .foregroundColor(.gray)
                                .italic()
                        } else {
                            ForEach(healthViewModel.indoorRuns, id: \.startDate) { run in
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Distance: \(run.distance / 1000, specifier: "%.2f") km")
                                    Text("Pace: \(run.pace / 60, specifier: "%.2f") min/km")
                                    Text("Calories: \(run.calories, specifier: "%.2f") kcal")
                                    Text("Duration: \(formatDuration(run.duration))")
                                }
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                            }
                        }
                    }
                    
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
    
    // 시간 포맷 함수
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return "\(minutes) min \(seconds) sec"
    }
}

#Preview {
    HealthDataView()
        .environmentObject(HealthKitViewModel.preview)
}
