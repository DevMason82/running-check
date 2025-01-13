//
//  SpeechModel.swift
//  DailyHope
//
//  Created by mason on 1/10/25.
//

import Foundation
import AVFoundation

struct SpeechModel {
    private let synthesizer = AVSpeechSynthesizer()
    
    func speak(text: String) {
        guard !text.isEmpty else { return }
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "ko-KR") // 언어 설정
        utterance.rate = 0.5 // 음성 속도 설정
        synthesizer.speak(utterance)
    }
}
