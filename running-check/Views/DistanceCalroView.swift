//
//  DistanceCalroView.swift
//  running-check
//
//  Created by mason on 12/4/24.
//

import SwiftUI

struct DistanceCalroView: View {
    let activeCalories: Double
    let runningDistance: Double
    var body: some View {
        VStack(alignment: .trailing) {
            HStack {
                VStack {
                    Text("총 이동 거리")
                        .font(.caption)
//                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("\(runningDistance / 1000, specifier: "%.2f") km")
                        .font(.title3)
                        .bold()
                        .foregroundColor(.blue)
//                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                Spacer()
                VStack {
                    Text("총 칼로리")
                        .font(.caption)
//                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("\(activeCalories, specifier: "%.1f") kcal")
                        .font(.title3)
                        .bold()
                        .foregroundColor(.red)
//                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
}

#Preview {
    DistanceCalroView(activeCalories: 450.5, runningDistance: 7321.4)
}
