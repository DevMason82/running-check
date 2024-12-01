//
//  WeatherCard.swift
//  running-check
//
//  Created by mason on 11/26/24.
//

import SwiftUI

struct WeatherCard: View {
    var title: String
    var value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.black.opacity(0.8))
            Text(value)
                .font(.body)
                .fontWeight(.bold)
                .foregroundColor(.blue)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: 100)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.8))
        )
    }
}

#Preview {
    WeatherCard(title: "풍속", value: "5 m/s")
}
