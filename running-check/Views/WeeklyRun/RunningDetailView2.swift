//
//  RunningDetailView.swift
//  running-check
//
//  Created by mason on 1/1/25.
//

import SwiftUI
import Photos

struct RunningDetailView2: View {
    let day: String
    let detail: RunningDayData
    @StateObject private var viewModel = WeeklyRunningDataViewModel()
    @State private var capturedImage: UIImage? = nil
    
    var body: some View {
        
        ZStack {
            Color("BackgroundColor")
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack {
                    if viewModel.isLoading {
                        LoadingView(message: "러닝체크 로딩중...🏃🏻‍♂️")
                            .transition(.opacity)
                    } else if viewModel.selectedDayDetails.isEmpty {
                        Text("해당 날짜의 러닝 기록이 없습니다.")
                            .padding()
                            .frame(maxWidth: .infinity)
                    } else {
                        ForEach(viewModel.selectedDayDetails) { detail in
                            DayRunningInfoDetailView(
                                distance: detail.distance,
                                duration: detail.duration,
                                calories: detail.calories,
                                heartRate: detail.heartRate,
                                pace: detail.pace,
                                cadence: detail.cadence
                            )
                        }
                    }
                }
                .onAppear {
                    Task {
                        await viewModel.fetchRunningDetails(for: day)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .navigationTitle(
                viewModel.selectedDayDetails.first.map { formatDate($0.date) } ?? "\(day) 러닝 기록"
            )
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
    
    private func convertViewToImage() -> UIImage {
        guard let detail = viewModel.selectedDayDetails.first else { return UIImage() }  // nil 체크
        let customView = CustomRunningDetailView(detail: detail)
        let controller = UIHostingController(rootView: customView)
        let view = controller.view
        
        let targetSize = CGSize(width: 400, height: 600)
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
    
//    private func captureAndSave() {
//        let image = convertViewToImage()
//        capturedImage = image
//        
//        PHPhotoLibrary.requestAuthorization { status in
//            switch status {
//            case .authorized, .limited:
//                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
//                print("이미지가 사진 앨범에 저장되었습니다.")
//            case .denied, .restricted:
//                print("사진 앨범 접근이 거부되었습니다.")
//            case .notDetermined:
//                print("권한 대기 중...")
//            @unknown default:
//                print("알 수 없는 상태.")
//            }
//        }
//    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy.MM.dd - HH:mm"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
}

// 커스텀 러닝 기록 뷰
struct CustomRunningDetailView: View {
    let detail: RunningDayData
    
    var body: some View {
        VStack(spacing: 16) {
            Text("🏃‍♂️ 러닝 기록")
                .font(.largeTitle)
                .bold()
            Text(formatDate(detail.date))
                .font(.headline)
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                Text("거리: \(String(format: "%.2f KM", detail.distance / 1000))")
                Text("시간: \(formatTime(detail.duration))")
                Text("칼로리: \(String(format: "%.0f KCAL", detail.calories))")
                Text("심박수: \(String(format: "%.0f BPM", detail.heartRate))")
                Text("페이스: \(formattedPace(detail.pace))")
                Text("케이던스: \(String(format: "%.0f SPM", detail.cadence))")
            }
            .font(.title3)
        }
        .padding()
        .cornerRadius(12)
        .shadow(radius: 5)
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
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "ko_KR")  // 한국어 날짜 포맷
        return formatter.string(from: date)
    }
    
    private func formattedPace(_ pace: Double) -> String {
        guard pace > 0 else { return "-" }
        let minutes = Int(pace) / 60
        let seconds = Int(pace) % 60
        return String(format: "%d'%02d\"", minutes, seconds)
    }
}

// 프리뷰에 날짜 데이터 추가
#Preview {
    RunningDetailView2(day: "Monday", detail: RunningDayData(date: Date(), distance: 100, duration: 60, calories: 100, heartRate: 100, pace: 100, cadence: 100))
}
