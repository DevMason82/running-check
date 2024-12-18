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
            VStack(alignment: .leading) {
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: 20) {
                        CoachCard(title: "러닝코멘트", content: coach.comment)
                        CoachCard(title: "러닝추천", content: coach.alternative)
                        CoachCard(title: "러닝용품", content: coach.gear)
                        CoachCard(title: "러닝화", content: coach.shoes)
                    }
                    .scrollTargetLayout()
                }
                .contentMargins(20, for: .scrollContent) // Add padding
                .scrollTargetBehavior(.viewAligned) // Align content behavior
                
            }
//            .padding(.horizontal)
        }
    }
}


struct CoachCard: View {
    let title: String
    let content: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .bold()
                .font(.subheadline)
                .foregroundColor(Color("CardFontColor"))
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(content)
                .bold()
//                .font(.system(size: 16))
                .font(.body)
                .foregroundColor(Color("CardFontColor"))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color("CardColor").opacity(0.5))
        .cornerRadius(10)
        .frame(width: UIScreen.main.bounds.width - 80)
        .scrollTransition { content, phase in
            content
                .opacity(phase.isIdentity ? 1 : 0.5) // Apply opacity animation
                .scaleEffect(y: phase.isIdentity ? 1 : 0.7) // Apply scale animation
        }
    }
}

#Preview {
    RunningCoachView(
        coach: RunningCoach(
            comment: "Great weather for running. Stay hydrated and enjoy your run!", alternative: "sdfsdjvlkjsdlkjsf",
            gear: "Light running clothes",
            shoes: "Cushioned running shoes"
        )
    )
    .environment(\.colorScheme, .light)
    .background(Color("BackgroundColor"))
}

#Preview {
    RunningCoachView(
        coach: RunningCoach(
            comment: "Great weather for running. Stay hydrated and enjoy your run!",
            alternative: "sdfsdjvlkjsdlkjsf",
            gear: "Light running clothes",
            shoes: "Cushioned running shoes"
        )
    )
    .environment(\.colorScheme, .dark)
    .background(Color("BackgroundColor"))
}
