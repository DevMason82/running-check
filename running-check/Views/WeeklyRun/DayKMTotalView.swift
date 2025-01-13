//
//  DayKMTotalView.swift
//  running-check
//
//  Created by mason on 12/28/24.
//

import SwiftUI

struct DayKMTotalView: View {
    let distance: Double // 총 거리 (km)
    //    let prevTotalDistance: Double // 이전 총 거리
    
    @State private var aniDistance: Double = 0
    @State private var showDiffer: Bool = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                Text(formattedValue(value: aniDistance))
                    .font(.system(size: 52))
                    .fontWeight(.heavy)
                    .contentTransition(.numericText())
                    .onAppear {
                        startAnimation()
                        //                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        //                            withAnimation(.interpolatingSpring(stiffness: 5, damping: 5)) {
                        //                                aniDistance = distance
                        //                            }
                        //                        }
                    }
                Text("킬로미터")
                    .font(.caption2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        //        .padding(.horizontal)
    }
    
    //    \(String(format: "%.2f", distance / 1000))KM
    
    // 값 포맷팅
    private func formattedValue(value: Double) -> String {
        return String(format: "%.2f", value / 1000)
    }
    
    // 애니메이션 시작
    private func startAnimation() {
        aniDistance = 0 // 애니메이션 시작값
        let stepCount = 50 // 애니메이션 단계 수
        let stepDuration = 1.0 / Double(stepCount) // 각 단계 간 시간
        
        Timer.scheduledTimer(withTimeInterval: stepDuration, repeats: true) { timer in
            let step = distance / Double(stepCount) // 단계별 증가량
            aniDistance += step
            
            if aniDistance >= distance { // 목표값에 도달 시 애니메이션 종료
                aniDistance = distance
                timer.invalidate()
            }
        }
    }
}

#Preview {
    DayKMTotalView(distance: 223.67)
}
