//
//  RunningGradeView.swift
//  running-check
//
//  Created by mason on 11/26/24.
//

import SwiftUI

struct RunningGradeView: View {
    let grade: RunningGrade

    
    @State private var isMovingVertically = false
    @State private var isMovingHorizontally = false
    
    var body: some View {
        VStack {
            Image(systemName: "figure.run")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .foregroundColor(colorForGrade(grade))
                .offset(x: isMovingHorizontally ? -2.5 : 5,
                        y: isMovingVertically ? -1.2 : 2.5)
                .animation(
                    Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true),
                    value: isMovingVertically
                )
                .animation(
                    Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true),
                    value: isMovingHorizontally
                )
                .onAppear {
                    isMovingVertically = true
                    isMovingHorizontally = true
                }
            
            Text(grade.rawValue)
                .font(.largeTitle)
                .bold()
                .foregroundColor(colorForGrade(grade))
            
        
        }
        .padding(.bottom, 5)
    }
}

#Preview {
    RunningGradeView(
        grade: .good
    )
}
