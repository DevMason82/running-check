//
//  GradientBackground.swift
//  running-check
//
//  Created by mason on 12/9/24.
//

import SwiftUI

struct GradientBackground: View {
    var runningGrade: RunningGrade // RunningGrade 타입을 사용
    
    var body: some View {
        gradientBackground
            .edgesIgnoringSafeArea(.all)
    }
    
    private var gradientBackground: LinearGradient {
        switch runningGrade {
        case .good:
            return LinearGradient(
                gradient: Gradient(colors: [Color(hex: "4FE768"), Color(hex: "1BA221")]),
                startPoint: .top,
                endPoint: .bottom
            )
        case .warning:
            return LinearGradient(
                gradient: Gradient(colors: [Color(hex: "FFAE00"), Color(hex: "FF6600")]),
                startPoint: .top,
                endPoint: .bottom
            )
        case .danger:
            return LinearGradient(
                gradient: Gradient(colors: [Color(hex: "FA3126"), Color(hex: "E51136")]),
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var hexNumber: UInt64 = 0
        scanner.scanHexInt64(&hexNumber)
        let r = Double((hexNumber & 0xFF0000) >> 16) / 255
        let g = Double((hexNumber & 0x00FF00) >> 8) / 255
        let b = Double(hexNumber & 0x0000FF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
