//
//  KMTotalView.swift
//  running-check
//
//  Created by mason on 12/28/24.
//

import SwiftUI

struct KMTotalView: View {
    let totalDistance: Double // 총 거리 (km)
    let prevTotalDistance: Double // 이전 총 거리
    
    @State private var aniDistance: Double = 0
    @State private var showDiffer: Bool = false
    
    var difference: Double {
        totalDistance - prevTotalDistance
    }
    
    var arrowImage: Image {
        if difference > 0 {
            return Image(systemName: "arrowtriangle.up.fill") // 증가
        } else if difference < 0 {
            return Image(systemName: "arrowtriangle.down.fill") // 감소
        } else {
            return Image(systemName: "minus") // 변화 없음
        }
    }
    
    var arrowColor: Color {
        difference > 0 ? .green : (difference < 0 ? .red : .gray)
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                Text(formattedValue(value: aniDistance))
                    .font(.system(size: 52))
                    .bold()
                    .contentTransition(.numericText())
                    .onAppear {
                        startAnimation()
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                            withAnimation(.interpolatingSpring(stiffness: 10, damping: 10)) {
//                                aniDistance = totalDistance
//                            }
//                        }
//                        
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                            self.showDiffer = true
//                        }
                    }
                Text("킬로미터")
            }
            // 변화량 및 화살표
            if showDiffer {
                HStack(spacing: 5) {
                    arrowImage
                        .foregroundColor(arrowColor)
                        .bold()
                    Text(formattedValue(value: difference))
                        .foregroundColor(arrowColor)
                        .bold()
                }
            }
            
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }
    
    // 값 포맷팅
    private func formattedValue(value: Double) -> String {
        return String(format: "%.2f", value)
    }
    
    // 애니메이션 시작
    private func startAnimation() {
        aniDistance = 0 // 초기값을 0으로 설정
        let stepCount = 50 // 애니메이션 단계 수
        let stepDuration = 1.0 / Double(stepCount) // 각 단계 간 시간
        
        Timer.scheduledTimer(withTimeInterval: stepDuration, repeats: true) { timer in
            let step = totalDistance / Double(stepCount) // totalDistance를 기준으로 단계를 나눔
            aniDistance += step
            
            if aniDistance >= totalDistance { // 목표값에 도달했을 때
                aniDistance = totalDistance
                timer.invalidate()
                
                // 변화량 표시 활성화
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.showDiffer = true
                }
            }
        }
    }
}

#Preview {
    KMTotalView(totalDistance: 256.89, prevTotalDistance: 228.60)
}
