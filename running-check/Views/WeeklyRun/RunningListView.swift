//
//  RunningListView.swift
//  running-check
//
//  Created by mason on 1/3/25.
//

import SwiftUI

struct RunningListView: View {
//    @StateObject private var viewModel: WeeklyRunningDataViewModel = WeeklyRunningDataViewModel()
    @EnvironmentObject private var viewModel: WeeklyRunningDataViewModel
    let day: String
    
    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .ignoresSafeArea()
            
            List {
                if viewModel.isLoading {
                    ProgressView("러닝 데이터 로드 중...🏃‍♂️")
                        .frame(maxWidth: .infinity, alignment: .center)
                } else if viewModel.selectedDayDetails.isEmpty {
                    VStack {
                        Text("해당 날짜에 러닝 기록이 없습니다.")
                            .font(.body)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
//                    .background(Color("BackgroundColor").opacity(0.1))
                } else {
                    ForEach(viewModel.selectedDayDetails, id: \.id) { detail in
                        NavigationLink(value: detail) {
                            RunningListRowView(detail: detail)
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
//            .background(Color("CardColor").opacity(0.1))
            .navigationTitle("\(day)요일")
            .onAppear {
                Task {
                    await viewModel.fetchRunningDetails(for: day)
                }
            }
            .navigationDestination(for: RunningDayData.self) { detail in
                RunningDetailView(day: day, detail: detail)  // RunningDetailView로 이동
            }
        }
    }
    
}

// 목록에서 보여질 러닝 기록 셀
struct RunningListRowView: View {
    let detail: RunningDayData
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(formatDate(detail.date))
                    .font(.subheadline)
                
                Text("거리: \(String(format: "%.2f KM", detail.distance / 1000))")
                    .font(.title2)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func formatTime(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        return hours > 0 ? String(format: "%02d:%02d", hours, minutes) : String(format: "%02d분", minutes)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy.MM.dd - HH:mm"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
}

#Preview {
    RunningListView(day: "Monday")
        .environmentObject(WeeklyRunningDataViewModel())
}
