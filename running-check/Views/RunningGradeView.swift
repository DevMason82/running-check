//
//  RunningGradeView.swift
//  running-check
//
//  Created by mason on 11/26/24.
//

import SwiftUI

//enum RunningGrade: String {
//    case good = "good"
//    case warning = "warning"
//    case danger = "danger"
//}

struct RunningGradeView: View {
    let grade: RunningGrade
    
    @State private var isMovingVertically = false
    @State private var isMovingHorizontally = false
    
    // RawValue를 한글 문자열로 변환하는 함수
    private func localizedGradeText(for grade: RunningGrade) -> String {
        switch grade {
        case .good:
            return "좋음"
        case .warning:
            return "경고"
        case .danger:
            return "위험"
        }
    }
    
    var body: some View {
        VStack {
            Image(systemName: "figure.run")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .foregroundColor(Color("CardFontColor"))
                .offset(x: isMovingHorizontally ? -2.5 : 5,
                        y: isMovingVertically ? -1.2 : 2.5)
                .animation(
                    Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true),
                    value: isMovingVertically
                )
                .animation(
                    Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true),
                    value: isMovingHorizontally
                )
                .onAppear {
                    isMovingVertically = true
                    isMovingHorizontally = true
                }
            
            // 변환된 한글 문자열 표시
            Text(localizedGradeText(for: grade))
                .font(.system(size: 48))
                .bold()
                .foregroundColor(Color("CardFontColor"))
        }
        .padding(.vertical, 15)
    }
}

#Preview {
    RunningGradeView(
        grade: .good
    )
    .background(Color.black)
}
