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
        VStack {
            ProgressView(message)
                .progressViewStyle(CircularProgressViewStyle())
                .padding()
            Text("Please wait while we fetch the latest weather data.")
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

#Preview {
    LoadingView(message: "Loading...")
}
