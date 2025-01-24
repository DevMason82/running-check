//
//  ChatGPTAPI.swift
//  running-check
//
//  Created by mason on 1/21/25.

import Foundation

struct ChatGPTRequest: Codable {
    let model: String
    let messages: [Message]
    let temperature: Double?
    
    struct Message: Codable {
        let role: String
        let content: String
    }
}

struct ChatGPTResponse: Codable {
    let choices: [Choice]
    
    struct Choice: Codable {
        let message: ChatGPTRequest.Message
    }
}

@MainActor
class ChatGPTAPI: ObservableObject {
    private let apiKey: String
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    func sendMessage(
        to model: String = "gpt-4o-mini",
        message: String,
        temperature: Double = 0.7
    ) async throws -> [String: [String: Any]] {
        let endpoint = URL(string: "https://api.openai.com/v1/chat/completions")!
        
        // ChatGPT 요청 메시지 설정
        let requestBody = ChatGPTRequest(
            model: model,
            messages: [
                .init(
                    role: "system",
                    content: """
                           너는 전문 러닝 코치야. 사용자가 제공하는 날씨 데이터를 분석하고, 러닝에 적합한 계획과 조언을 제공해야 해. 
                           
                           응답은 반드시 순수 JSON 객체만 반환하고, 코드 블록이나 불필요한 텍스트를 포함하지 마.
                           응답 형식은 다음과 같아야 해:
                           {
                             "runningIntro": {
                               "id": 1,
                               "description": "날씨와 관련된 러닝정보 소개"
                             },
                             "runningStatus": {
                               "id": 2,
                               "description": "사용자가 러닝을 시작하기에 적합한지 판단"
                             },
                             "runningPlace": {
                               "id": 3,
                               "description": "러닝 장소가 실외인지 실내인지 여부"
                             },
                             "runningPlane": {
                               "id": 4,
                               "description": "러닝 장소에 따른 세부 계획"
                             },
                             "runningEqpmnt": {
                               "id": 5,
                               "description": "러닝 장소에 따른 장비 추천"
                             },
                             "runningPreventionOfInjury": {
                               "id": 6,
                               "description": "러닝 부상 방지"
                             },
                             "runningRecovery": {
                               "id": 7,
                               "description": "러닝 후 회복 방법"
                             },
                             "runningAfterEat": {
                               "id": 8,
                               "description": "러닝 후 영양 섭취"
                             },
                             "runningEnd": {
                               "id": 9,
                               "description": "러닝 코칭 끝인사"
                             }
                           }
                           
                           다시 말하지만, 순수 JSON 데이터만 반환하고, 구체적이고 현실적이어야 해. 필요하면 단계별 안내와 명확한 근거를 포함하고, 긍정적이고 격려하는 어조로 작성해줘.
                           """
                ),
                .init(role: "user", content: message)
            ],
            temperature: temperature
        )
        
        // JSON 인코딩
        let requestData = try JSONEncoder().encode(requestBody)
        
        // URL 요청 구성
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = requestData
        
        // URLSession을 사용해 API 호출
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // HTTP 응답 확인
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let errorResponse = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw NSError(domain: "ChatGPTAPI", code: 1, userInfo: [NSLocalizedDescriptionKey: errorResponse])
        }
        
        // JSON 디코딩
        let decodedResponse = try JSONDecoder().decode(ChatGPTResponse.self, from: data)
        let fullContent = decodedResponse.choices.first?.message.content ?? "{}"
        
        // JSON 문자열에서 순수 JSON 객체로 파싱
        guard let jsonData = cleanAndParseJSON(fullContent) else {
            throw NSError(domain: "ChatGPTAPI", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON structure"])
        }
        
        // JSON 객체 반환
        return jsonData
    }
    
    /// JSON 문자열을 정리하고 [String: [String: Any]]으로 반환
    private func cleanAndParseJSON(_ jsonString: String) -> [String: [String: Any]]? {
        // JSON 시작 및 끝 추출
        guard let jsonStartIndex = jsonString.firstIndex(of: "{"),
              let jsonEndIndex = jsonString.lastIndex(of: "}") else {
            return nil
        }
        
        // 순수 JSON 문자열 추출
        let pureJSONString = String(jsonString[jsonStartIndex...jsonEndIndex])
        
        // JSON 디코딩
        guard let jsonData = pureJSONString.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: [String: Any]] else {
            return nil
        }
        
        return jsonObject
    }
}
