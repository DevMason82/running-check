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
    
//    var difference: Double {
//        totalDistance - prevTotalDistance
//    }
    
//    var arrowImage: Image {
//        if difference > 0 {
//            return Image(systemName: "arrowtriangle.up.fill") // 증가
//        } else if difference < 0 {
//            return Image(systemName: "arrowtriangle.down.fill") // 감소
//        } else {
//            return Image(systemName: "minus") // 변화 없음
//        }
//    }
//    
//    var arrowColor: Color {
//        return difference > 0 ? .green : .red
//    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                Text(formattedValue(value: aniDistance))
                    .font(.system(size: 52))
                    .fontWeight(.heavy)
                    .contentTransition(.numericText())
                    .onAppear {
//                        withAnimation(.easeOut(duration: 1)) {
//                            self.aniDistance = self.totalDistance
//                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            withAnimation(.interpolatingSpring(stiffness: 5, damping: 5)) {
                                aniDistance = distance
                            }
                        }
                        
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
//                            self.showDiffer = true
//                        }
                    }
                Text("킬로미터")
                    .font(.caption2)
            }
            // 변화량 및 화살표
//            if showDiffer {
//                HStack(spacing: 5) {
//                    arrowImage
//                        .foregroundColor(arrowColor)
//                        .bold()
//                    Text(formattedValue(value: difference))
//                        .foregroundColor(arrowColor)
//                        .bold()
//                }
//            }
            
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
//        .padding(.horizontal)
    }
    
//    \(String(format: "%.2f", distance / 1000))KM
    
    // 값 포맷팅
    private func formattedValue(value: Double) -> String {
        return String(format: "%.2f", value / 1000)
    }
}

#Preview {
    DayKMTotalView(distance: 223.67)
}
