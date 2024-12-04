//
//  SwiftUIView.swift
//  running-check
//
//  Created by mason on 11/26/24.
//

import SwiftUI

struct RunningCoachView: View {
    let coach: RunningCoach?
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        if let coach = coach {
            VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("러닝코멘트")
                        .font(.headline)
                        .padding(.bottom, 5)
                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .foregroundColor(Color("CardFontColor"))
                    Text(coach.comment)
                        .font(.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color("CardColor"))
                )
//                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("러닝용품")
                        .font(.headline)
                        .padding(.bottom, 5)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(coach.gear)
                        .font(.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color("CardColor"))
                )
//                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("러닝화")
                        .font(.headline)
                        .padding(.bottom, 5)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(coach.shoes)
                        .font(.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color("CardColor"))
                )
                .frame(maxWidth: .infinity, alignment: .leading)
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
//            .background(Color.brown)
            .padding(0)
            .padding(.horizontal)
            
        }
    }
}

#Preview {
    RunningCoachView(
        coach: RunningCoach(
            comment: "Great weather for running. Stay hydrated and enjoy your run!",
            gear: "Light running clothes",
            shoes: "Cushioned running shoes"
        )
    )
}
