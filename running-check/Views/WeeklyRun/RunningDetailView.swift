//
//  RunningDetailView.swift
//  running-check
//
//  Created by mason on 1/3/25.
//

import SwiftUI
import Photos

struct RunningDetailView: View {
    let day: String
    let detail: RunningDayData
    @State private var capturedImage: UIImage? = nil
    
    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                DayRunningInfoDetailView(
                    distance: detail.distance,
                    duration: detail.duration,
                    calories: detail.calories,
                    heartRate: detail.heartRate,
                    pace: detail.pace,
                    cadence: detail.cadence
                )
            }
            .onAppear() {
                captureAndSave()
            }
            .navigationTitle(formatDate(detail.date))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if let capturedImage = capturedImage {
                        ShareLink(item: Image(uiImage: capturedImage),
                                  preview: SharePreview("러닝 기록", image: Image(uiImage: capturedImage))) {
                            Image(systemName: "square.and.arrow.up")
                                .imageScale(.large)
                        }
                    }
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy.MM.dd - HH:mm"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
    
    private func convertViewToImage() -> UIImage {
        let customView = NewCustomRunningDetailView(detail: detail)  // detail은 non-optional
        let controller = UIHostingController(rootView: customView)
        let view = controller.view
        
        let targetSize = CGSize(width: 300, height: 600)
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { context in
            view?.drawHierarchy(in: view!.bounds, afterScreenUpdates: true)
        }
    }
    
    private func captureAndSave() {
        let image = convertViewToImage()
        capturedImage = image
        
        // 앨범 저장 부분 제거
        print("이미지가 캡처되었습니다.")
    }
}

// 커스텀 러닝 기록 뷰
struct NewCustomRunningDetailView: View {
    let detail: RunningDayData
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Text("러닝체크")
                    .font(.title3)
                    .bold()
                Spacer()
                Text(formatDate(detail.date))
                    .font(.subheadline)
            }
            .padding(.bottom, 15)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("거리: \(String(format: "%.2f KM", detail.distance / 1000))")
                Text("평균 페이스: \(formattedPace(detail.pace))")
                Text("시간: \(formatTime(detail.duration))")
                Text("칼로리: \(String(format: "%.0f KCAL", detail.calories))")
                Text("평균 심박수: \(String(format: "%.0f BPM", detail.heartRate))")
                Text("평균 케이던스: \(String(format: "%.0f SPM", detail.cadence))")
            }
            .font(.body)
        }
        .padding()
        .background(Color("CardColor").opacity(0.1))
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        .cornerRadius(10)
    }
    
    // 시간 포맷 (초 → 시:분:초)
    private func formatTime(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        let seconds = Int(interval) % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    // 날짜 포맷 (Date → String)
//    private func formatDate(_ date: Date) -> String {
//        let formatter = DateFormatter()
//        formatter.dateStyle = .medium
//        formatter.locale = Locale(identifier: "ko_KR")  // 한국어 날짜 포맷
//        return formatter.string(from: date)
//    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy.MM.dd - HH:mm"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
    
    private func formattedPace(_ pace: Double) -> String {
        guard pace > 0 else { return "-" }
        let minutes = Int(pace) / 60
        let seconds = Int(pace) % 60
        return String(format: "%d'%02d\"", minutes, seconds)
    }
}

#Preview {
    RunningDetailView(
        day: "Monday",
        detail: RunningDayData(date: Date(), distance: 100, duration: 60, calories: 100, heartRate: 100, pace: 100, cadence: 100)
    )
}
