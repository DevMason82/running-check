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
                    .foregroundColor(Color("AccentColor"))
                    .bold()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    LoadingView(message: "러닝체크 로딩중...🏃🏻‍♂️")
}
