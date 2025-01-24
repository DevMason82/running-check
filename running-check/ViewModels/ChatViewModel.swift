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
    
    init() {
        guard let apiKey = ProcessInfo.processInfo.environment["CHATGPT_API_KEY"] else {
            fatalError("API_KEY 환경변수가 설정되지 않았습니다.")
        }
        self.chatAPI = ChatGPTAPI(apiKey: apiKey)
    }
    
    func sendMessage() async {
        guard !userMessage.isEmpty else { return }
        
        isLoading = true
        do {
            let response = try await chatAPI.sendMessage(message: userMessage)
            chatResponse = response // ChatGPT 응답 저장
        } catch {
            chatResponse = [
                "오류": [
                    "description": "오류 발생: \(error.localizedDescription)"
                ]
            ]
        }
        isLoading = false
    }
}
