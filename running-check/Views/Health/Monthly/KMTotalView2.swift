//
//  KMTotalView2.swift
//  running-check
//
//  Created by mason on 12/28/24.
//

import SwiftUI

struct KMTotalView2: View {
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
        return difference > 0 ? .green : .red
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                Text(formattedValue(value: totalDistance))  // 애니메이션 없이 즉시 표시
                    .font(.system(size: 42))
                    .bold()
                Text("킬로미터")
                    .font(.system(size: 12))
            }
            // 변화량 및 화살표
            HStack(spacing: 5) {
                arrowImage
                    .foregroundColor(arrowColor)
                    .bold()
                Text(formattedValue(value: difference))
                    .foregroundColor(arrowColor)
                    .bold()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
//        .padding(.horizontal)
    }
    
    // 값 포맷팅
    private func formattedValue(value: Double) -> String {
        return String(format: "%.2f", value)
    }
}

#Preview {
    KMTotalView2(totalDistance: 223.67, prevTotalDistance: 200)
}
