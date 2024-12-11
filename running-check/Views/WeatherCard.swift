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
                .foregroundColor(Color("CardFontColor"))
            Text(value)
                .font(.body)
                .fontWeight(.bold)
                .foregroundColor(Color("CardFontColor"))
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: 100)
        .background(Color("CardColor").opacity(0.3))
        .cornerRadius(10)
    }
}

#Preview {
    WeatherCard(title: "풍속", value: "5 m/s")
}
