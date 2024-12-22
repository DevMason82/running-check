//
//  SwiftUIView.swift
//  running-check
//
//  Created by mason on 11/26/24.
//

import SwiftUI

struct RunningCoachView: View {
    let coach: RunningCoach?
    let grade: RunningGrade?
    @Environment(\.colorScheme) private var colorScheme
    
    private func localizedGradeText(for grade: RunningGrade) -> String {
        switch grade {
        case .good:
            return "좋음"
        case .warning:
            return "경고"
        case .danger:
            return "위험"
        }
    }

    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .ignoresSafeArea()
            
            if let coach = coach {
                VStack(alignment: .leading) {
                    ScrollView( showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 20) {
                            CoachCard(title: "피드백", content: coach.comment)
                            CoachCard(title: "계획", content: coach.alternative)
                            CoachCard(title: "용품", content: coach.gear)
                            CoachCard(title: "신발", content: coach.shoes)
                        }
                        .scrollTargetLayout()
                    }
                    .navigationTitle("\(localizedGradeText(for: grade!))")
                    .navigationBarTitleDisplayMode(.large)
                    .foregroundStyle(Color("AccentColor"))
                    .frame(maxWidth: .infinity)
    //                .contentMargins(20, for: .scrollContent) // Add padding
    //                .scrollTargetBehavior(.viewAligned) // Align content behavior
                    
    //                ScrollView(.horizontal, showsIndicators: false) {
    //                    HStack(alignment: .top, spacing: 20) {
    //                        CoachCard(title: "러닝코멘트", content: coach.comment)
    //                        CoachCard(title: "러닝추천", content: coach.alternative)
    //                        CoachCard(title: "러닝용품", content: coach.gear)
    //                        CoachCard(title: "러닝화", content: coach.shoes)
    //                    }
    //                    .scrollTargetLayout()
    //                }
    //                .navigationTitle("러닝 코치")
    //                .navigationBarTitleDisplayMode(.large)
    //                .contentMargins(20, for: .scrollContent) // Add padding
    //                .scrollTargetBehavior(.viewAligned) // Align content behavior
                    
                }
                .padding(.horizontal)
            }
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
                .font(.title3)
//                .foregroundColor(Color("CardFontColor"))
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(content)
                .bold()
                .font(.system(size: 18))
//                .font(.body)
//                .foregroundColor(Color("CardFontColor"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineSpacing(3.5)
        }
        .padding()
        .background(Color("CardColor").opacity(0.3))
        .cornerRadius(10)
//        .frame(width: UIScreen.main.bounds.width - 80)
//        .scrollTransition { content, phase in
//            content
//                .opacity(phase.isIdentity ? 1 : 0.5) // Apply opacity animation
//                .scaleEffect(y: phase.isIdentity ? 1 : 0.7) // Apply scale animation
//        }
    }
}

#Preview {
    RunningCoachView(
        coach: RunningCoach(
            simpleFeedback: "sdlkjsdflkj",
            comment: "Great weather for running. Stay hydrated and enjoy your run!",
            alternative: "sdfsdjvlkjsdlkjsf",
            gear: "Light running clothes",
            shoes: "Cushioned running shoes"
        ), grade: .good
    )
    .environment(\.colorScheme, .light)
    .background(Color("BackgroundColor"))
}

#Preview {
    RunningCoachView(
        coach: RunningCoach(
            simpleFeedback: "sdlkjsdflkj",
            comment: "Great weather for running. Stay hydrated and enjoy your run!",
            alternative: "sdfsdjvlkjsdlkjsf",
            gear: "Light running clothes",
            shoes: "Cushioned running shoes"
        ), grade: .warning
    )
    .environment(\.colorScheme, .dark)
    .background(Color("BackgroundColor"))
}
