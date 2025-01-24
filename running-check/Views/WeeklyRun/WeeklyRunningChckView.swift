//
//  WeeklyRunningChckView.swift
//  running-check
//
//  Created by mason on 1/1/25.
//

import SwiftUI

struct WeeklyRunningChckView: View {
    let weeklyRunningStatus: [RunningDayStatus]
   
    var body: some View {
        VStack {
            Text("\(formattedCurrentMonthYear())")
                .font(.title)
                .bold()
                .foregroundColor(Color("CardFontColor"))
                .padding(.bottom, 15)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                ForEach(weeklyRunningStatus) { status in
                    NavigationLink(value: status.day) {  // NavigationLink 사용
                        VStack {
                            Image(systemName: status.hasRun ? "checkmark.seal" : "x.circle")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 32, height: 32)
                                .foregroundColor(Color("CardFontColor"))
                                .opacity(status.hasRun ? 1.0 : 0.3)
                            
                            Text(status.day.prefix(3))
                                .font(.headline)
                                .foregroundColor(Color("CardFontColor"))
                                .opacity(status.hasRun ? 1.0 : 0.3)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .disabled(!status.hasRun)
                }
            }
            .navigationDestination(for: String.self) { day in
                RunningListView(day: day)  // 선택한 day 값으로 RunningListView 이동
            }
            .padding(.bottom, 10)
            
            Spacer()
            
            VStack {
                NavigationLink(destination: MonthlyRunningDataView()) {
                    HStack {
                        Text("이번달 상세 기록")
                            .font(.headline)
                            .foregroundColor(Color("CardFontColor"))
                        Image(systemName: "arrow.forward")
                            .font(.title3)
                            .foregroundColor(Color("CardFontColor"))
                    }
                    .frame(maxWidth: .infinity,  alignment: .trailing)
                }
                Spacer()
            }
            
        }
        .padding(.horizontal)
        
    }
    
    private func formattedCurrentMonthYear() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy년 M월"
        let monthYear = dateFormatter.string(from: Date())
        
        let calendar = Calendar.current
        let currentWeek = calendar.component(.weekOfMonth, from: Date())
        
        return "\(monthYear) \(currentWeek)주차 러닝"
    }
}

#Preview {
    WeeklyRunningChckView(
        weeklyRunningStatus: [
            RunningDayStatus(day: "일", hasRun: false),
            RunningDayStatus(day: "월", hasRun: true),
            RunningDayStatus(day: "화", hasRun: false),
            RunningDayStatus(day: "수", hasRun: true),
            RunningDayStatus(day: "목", hasRun: false),
            RunningDayStatus(day: "금", hasRun: true),
            RunningDayStatus(day: "토", hasRun: true)
            
        ]
    )
    .background(Color("BackgroundColor"))
}
