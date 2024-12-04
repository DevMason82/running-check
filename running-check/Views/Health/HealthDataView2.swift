//
//  HealthDataView.swift
//  running-check
//
//  Created by mason on 11/30/24.
//

import SwiftUI

struct HealthDataView2: View {
//    let activeCalories: Double
//    let runningDistance: Double
    let outdoorRuns: [RunData]
    let indoorRuns: [RunData]
    //    @EnvironmentObject var healthViewModel: HealthKitViewModel
    
    
    var body: some View {
        VStack(alignment: .leading) {
//            HStack {
//                VStack {
//                    Text("총 이동 거리")
//                        .font(.caption)
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                    Text("\(runningDistance / 1000, specifier: "%.2f") km")
//                        .font(.title2)
//                        .bold()
//                        .foregroundColor(.blue)
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                }
//                Spacer()
//                VStack {
//                    Text("총 칼로리")
//                        .font(.caption)
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                    Text("\(activeCalories, specifier: "%.1f") kcal")
//                        .font(.title2)
//                        .bold()
//                        .foregroundColor(.red)
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                }
//            }
//            .padding(.bottom, 10)
            
            HStack(alignment: .top, spacing: 20) {
                // 실외 러닝 정보
                VStack(alignment: .leading, spacing: 10) {
                    Text("실외 러닝")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if outdoorRuns.isEmpty {
                        Text("실외 러닝 정보 없습니다.")
                            .foregroundColor(.gray)
                            .italic()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        ForEach(outdoorRuns, id: \.startDate) { run in
                            VStack(alignment: .leading, spacing: 8) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("운동 시간")
                                        .font(.caption)
                                        .bold()
                                    Text("\(formatDuration(run.duration))")
                                        .font(.title2)
                                        .bold()
                                        .foregroundColor(.yellow)
                                        
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("거리")
                                        .font(.caption)
                                        .bold()
                                    Text("\(run.distance / 1000, specifier: "%.2f") km")
                                        .font(.title2)
                                        .bold()
                                        .foregroundColor(.blue)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("칼로리")
                                        .font(.caption)
                                        .bold()
                                    Text("\(run.calories, specifier: "%.1f") kcal")
                                        .font(.title2)
                                        .bold()
                                        .foregroundColor(.red)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("페이스")
                                        .font(.caption)
                                        .bold()
                                    Text("\(run.pace / 60, specifier: "%.2f")/km")
                                        .font(.title2)
                                        .bold()
                                        .foregroundColor(.mint)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(10)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // 실내 러닝 정보
                VStack(alignment: .leading, spacing: 10) {
                    Text("실내 러닝")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if indoorRuns.isEmpty {
                        Text("실내 러닝 정보 없습니다.")
                            .foregroundColor(.gray)
                            .italic()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        ForEach(indoorRuns, id: \.startDate) { run in
                            VStack(alignment: .leading, spacing: 8) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("운동 시간")
                                        .font(.caption)
                                        .bold()
                                    Text("\(formatDuration(run.duration))")
                                        .font(.title2)
                                        .bold()
                                        .foregroundColor(.yellow)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("거리")
                                        .font(.caption)
                                        .bold()
                                    Text("\(run.distance / 1000, specifier: "%.2f") km")
                                        .font(.title2)
                                        .bold()
                                        .foregroundColor(.blue)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("칼로리")
                                        .font(.caption)
                                        .bold()
                                    Text("\(run.calories, specifier: "%.1f") kcal")
                                        .font(.title2)
                                        .bold()
                                        .foregroundColor(.red)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("페이스")
                                        .font(.caption)
                                        .bold()
                                    Text("\(run.pace / 60, specifier: "%.2f")/km")
                                        .font(.title2)
                                        .bold()
                                        .foregroundColor(.mint)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(10)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal)
    }
    
    
    // 시간 포맷 함수
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let seconds = Int(duration) % 60
        
        if hours > 0 {
            return "\(hours):\(String(format: "%02d", minutes)):\(String(format: "%02d", seconds))"
        } else {
            return "\(minutes):\(String(format: "%02d", seconds))"
        }
    }
}

#Preview {
    HealthDataView2(outdoorRuns: [
        RunData(
            duration: 1800, // 30 minutes
            distance: 5000, // 5 km
            calories: 320.5,
            pace: 360, // 6 min/km
            startDate: Date(),
            endDate: Date()
        )
    ], indoorRuns: [
        RunData(
            duration: 1500, // 25 minutes
            distance: 3000, // 3 km
            calories: 200.0,
            pace: 300, // 5 min/km
            startDate: Date(),
            endDate: Date()
        )
    ])
}
