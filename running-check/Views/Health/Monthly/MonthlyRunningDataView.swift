//
//  MonthlyRunningDataView.swift
//  running-check
//
//  Created by mason on 12/12/24.
//

import SwiftUI

struct MonthlyRunningDataView: View {
    @StateObject private var healthViewModel = HealthKitViewModel()
    @State private var isLoading = true // 로딩 상태를 관리
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            if isLoading {
                // 로딩 UI
                PendingView(message: "\(healthViewModel.currentMonth) 러닝 기록 가져오는 중입니다...")
            } else {
                VStack {
                    if healthViewModel.totalRunningDistance > 0 {
                        MonthlyInfoView(
                            totalRunningDistance: healthViewModel.totalRunningDistance,
                            totalCaloriesBurned: healthViewModel.totalCaloriesBurned,
                            totalRunningTime: healthViewModel.totalRunningTime,
                            averagePace: healthViewModel.averagePace,
                            averageCadence: healthViewModel.averageCadence,
                            indoorRunCount: healthViewModel.indoorRunCount,
                            outdoorRunCount: healthViewModel.outdoorRunCount
                        )
                    } else {
                        NoDataView()
                    }
                }
                .padding()
            }
        }
        .navigationTitle("\(healthViewModel.currentMonth) 러닝 기록")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            fetchData()
        }
    }
    
    private func fetchData() {
        Task {
            isLoading = true
            await healthViewModel.fetchMonthlyData()
            isLoading = false
        }
    }
}

// 로딩 뷰
struct PendingView: View {
    let message: String
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
                Text(message)
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// 헤더 뷰
struct HeaderView: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.title)
            .bold()
            .padding(.bottom, 20)
    }
}

// 데이터가 없을 때의 뷰
struct NoDataView: View {
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack {
                Text("이번 달 데이터가 없습니다.")
                    .foregroundColor(.secondary)
                    .font(.headline)
                    .padding()
            }
        }
    }
}

#Preview {
    MonthlyRunningDataView()
    
}
