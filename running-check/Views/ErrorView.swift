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
        VStack {
            Text(errorMessage)
                .foregroundColor(.red)
                .multilineTextAlignment(.center)
                .padding()
            
            Button("위치 권한 설정으로 이동", action: onSettingsTap)
                .foregroundColor(.blue)
                .padding()
        }
    }
}

#Preview {
    ErrorView(errorMessage: "Unable to fetch location. Please check your location settings.",
              onSettingsTap: {})
}
