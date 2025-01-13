//
//  SpeechViewModel.swift
//  DailyHope
//
//  Created by mason on 1/10/25.
//

import Foundation

class SpeechViewModel: ObservableObject {
    @Published var inputText: String = ""
    
    private let speechModel = SpeechModel()
    
    func speakText() {
        speechModel.speak(text: inputText)
    }
}
