//
//  ColorHelper.swift
//  running-check
//
//  Created by mason on 11/22/24.
//

import Foundation
import SwiftUI

func colorForGrade(_ grade: RunningGrade) -> Color {
    switch grade {
    case .good:
        return Color("GoodGradeColor")
    case .warning:
        return Color("WarningGradeColor")
    case .danger:
        return Color("DangerGradeColor")
    }
}

func gradeColor(for grade: RunningGrade) -> Color {
    switch grade {
    case .good: return Color("GoodGradeColor")
    case .warning: return .orange
    case .danger: return .red
    }
}

func gradeBackground(for grade: RunningGrade) -> Color {
    switch grade {
    case .good: return Color.green.opacity(0.2)
    case .warning: return Color.orange.opacity(0.2)
    case .danger: return Color.red.opacity(0.2)
    }
}
