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
            Text(value)
                .font(.body)
                .fontWeight(.bold)
                .foregroundColor(.blue)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: 100)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

#Preview {
    WeatherCard(title: "풍속", value: "5 m/s")
}
