//
//  AICoachRowView.swift
//  running-check
//
//  Created by mason on 1/24/25.
//

import SwiftUI

struct AICoachRowView: View {
    var key: String
    var description: String
    
    /// 영어 key를 한글로 매핑
    private var localizedKey: String {
        let keyMapping: [String: String] = [
            "runningIntro": "러닝 소개 🌟",
            "runningStatus": "러닝 상태 🏃‍♂️",
            "runningPlace": "러닝 장소 📍",
            "runningPlane": "러닝 계획 📝",
            "runningEqpmnt": "러닝 장비 🎒",
            "runningPreventionOfInjury": "부상 방지 🛡️",
            "runningRecovery": "운동 후 회복 💪",
            "runningAfterEat": "운동 후 영양 섭취 🍎",
            "runningEnd": "코칭 끝인사 👋"
        ]
        return keyMapping[key] ?? key // 매핑되지 않은 경우 기본적으로 영어 키 표시
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
                    // 헤더 (한글 키와 이모지)
                    HStack(spacing: 10) {
//                        Image(systemName: "info.circle.fill")
//                            .foregroundColor(.blue)
//                            .font(.title3)
                        
                        Text(localizedKey)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.headline)
                            .foregroundColor(Color("AccentColor"))
                            
                    }
                    
                    // 설명 텍스트
                    Text(description)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.body)
                        .foregroundColor(Color("AccentColor"))
//                        .padding()
//                        .background(
//                            RoundedRectangle(cornerRadius: 12)
//                                .fill(Color(.systemGray6)) // iOS 스타일 배경색
//                        )
                }
//                .padding()
//                .padding(.vertical, 10)
//                .padding(.horizontal, 16)
//                .background(
//                    RoundedRectangle(cornerRadius: 16)
//                        .fill(Color.white) // 카드 스타일 배경
//                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
//                )
                
    }
}

#Preview {
    AICoachRowView(key: "runningIntro", description: "너는 전문 러닝 코치야. 사용자가 제공하는 날씨 데이터를 분석하고, 러닝에 적합한 계획과 조언을 제공해야 해. ")
}
