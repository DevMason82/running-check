//
//  ErrorView.swift
//  running-check
//
//  Created by mason on 11/26/24.
//

import SwiftUI

struct ErrorView: View {
    let errorMessage: String
    let onSettingsTap: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // 에러 아이콘
            Image(systemName: "location.slash")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.red.opacity(0.8))
                .padding(.top, 50)
            
            // 에러 메시지
            Text("문제가 발생했어요!")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.black)
            
            Text(errorMessage)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // 설정 이동 버튼
            Button(action: onSettingsTap) {
                Text("위치 권한 설정으로 이동")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 30)
//            .shadow(radius: 3)
            
            Spacer()
        }
//        .background(Color(.systemGray6))
        .cornerRadius(15)
//        .shadow(radius: 5)
        .padding()
    }
}

#Preview {
    ErrorView(errorMessage: "현재 위치를 가져올 수 없습니다.\n위치 설정을 확인해 주세요.",
              onSettingsTap: {})
}
