//
//  DayKMTotalView2.swift
//  running-check
//
//  Created by mason on 12/28/24.
//

import SwiftUI

struct DayKMTotalView2: View {
    let distance: Double // 총 거리 (km)
    @State private var aniDistance: Double = 0
    @State private var showDiffer: Bool = false
        
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                Text(formattedValue(value: distance))
                    .font(.system(size: 52))
                    .fontWeight(.heavy)
                    .contentTransition(.numericText())
//                    .onAppear {
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                            withAnimation(.interpolatingSpring(stiffness: 5, damping: 5)) {
//                                aniDistance = distance
//                            }
//                        }
//                    }
                Text("킬로미터")
                    .font(.caption2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
        
    // 값 포맷팅
    private func formattedValue(value: Double) -> String {
        return String(format: "%.2f", value / 1000)
    }
}

#Preview {
    DayKMTotalView2(distance: 223.67)
}
