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
                        .bold()
                        .font(.caption)
                        .foregroundColor(Color("CardFontColor"))
                        .padding(.bottom, 5)
                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .foregroundColor(Color("CardFontColor"))
                    Text(coach.comment)
                        .bold()
                        .font(.body)
                        .foregroundColor(Color("CardFontColor"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .background(Color("CardColor").opacity(0.3))
                .cornerRadius(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("러닝용품")
                        .bold()
                        .font(.caption)
                        .foregroundColor(Color("CardFontColor"))
                        .padding(.bottom, 5)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(coach.gear)
                        .bold()
                        .font(.body)
                        .foregroundColor(Color("CardFontColor"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .background(Color("CardColor").opacity(0.3))
                .cornerRadius(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("러닝화")
                        .bold()
                        .font(.caption)
                        .foregroundColor(Color("CardFontColor"))
                        .padding(.bottom, 5)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(coach.shoes)
                        .bold()
                        .font(.body)
                        .foregroundColor(Color("CardFontColor"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .background(Color("CardColor").opacity(0.3))
                .cornerRadius(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
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
