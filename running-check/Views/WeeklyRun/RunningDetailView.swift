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
        VStack {
            HStack {
                Text("러닝체크")
                    .font(.title3)
                    .bold()
                Spacer()
                Text(formatDate(detail.date))
                    .font(.title3)
            }
            DayRunningInfoDetailView2(
                distance: detail.distance,
                duration: detail.duration,
                calories: detail.calories,
                heartRate: detail.heartRate,
                pace: detail.pace,
                cadence: detail.cadence
            )
        }
        .padding()
        .background(Color("BackgroundColor").opacity(0.1))
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
        detail: RunningDayData(date: Date(), distance: 1300, duration: 60, calories: 100, heartRate: 100, pace: 100, cadence: 100)
    )
}
