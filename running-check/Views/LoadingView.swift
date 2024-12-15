//
//  LoadingView.swift
//  running-check
//
//  Created by mason on 11/26/24.
//

import SwiftUI

struct LoadingView: View {
    let message: String
    
    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .ignoresSafeArea()
            
            VStack {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color("ProgressColor")))
                    .scaleEffect(1.5)
                    .padding()
                Text(message)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .bold()
            }
//            .background(
//                RoundedRectangle(cornerRadius: 20)
//                    .fill(Color(.systemBackground).opacity(0.9)) // 반투명 배경
//                    .shadow(color: .black.opacity(0.1), radius: 10, x: 1, y: 8) // 그림자 추가
//            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    LoadingView(message: "러닝체크 로딩중...🏃🏻‍♂️")
}
