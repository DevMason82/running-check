//
//  ChatViewModel.swift
//  running-check
//
//  Created by mason on 1/21/25.
//

import Foundation

@MainActor
class ChatViewModel: ObservableObject {
    @Published var userMessage: String = "" // 사용자 입력
    @Published var chatResponse: [String: [String: Any]] = [:] // ChatGPT 응답
    @Published var isLoading: Bool = false
    
    private let chatAPI: ChatGPTAPI
    
    // 하드코딩된 API 키
    private let apiKey: String = "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"

    init() {
        // 하드코딩된 API 키를 사용하여 ChatGPTAPI 초기화
        self.chatAPI = ChatGPTAPI(apiKey: apiKey)
    }
    
    func sendMessage() async {
        guard !userMessage.isEmpty else { return } // 사용자 입력이 비어 있으면 실행 중단
        
        isLoading = true // 로딩 상태 활성화
        do {
            let response = try await chatAPI.sendMessage(message: userMessage) // ChatGPT API 호출
            chatResponse = response // 응답 데이터를 저장
        } catch {
            chatResponse = [
                "오류": [
                    "description": "오류 발생: \(error.localizedDescription)"
                ]
            ]
        }
        isLoading = false // 로딩 상태 비활성화
    }
}
