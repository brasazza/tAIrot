//
//  OpenAIService.swift
//  tAIrot
//
//  Created by Brandon Ramírez Casazza on 17/05/23.
//

import Foundation
import Alamofire

struct ChatCompletion: Codable {
    let id: String
    let object: String
    let created: Int
    let model: String
    let choices: [Choice]
    
    struct Choice: Codable {
        let message: Message
        let finish_reason: String
        let index: Int
    }
    
    struct Message: Codable {
        let role: String
        let content: String
    }
}

class OpenAIService {
    
    static let shared = OpenAIService()
    
    func createChatCompletion(prompt: String, completion: @escaping (Result<String, Error>) -> Void) {
        let apiURL = "https://api.openai.com/v1/chat/completions"
        let headers: HTTPHeaders = [
            "Authorization": "Bearer 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",
            "Content-Type": "application/json"
        ]
        let parameters: Parameters = [
            "model": "gpt-3.5-turbo",
            "messages": [["role": "user", "content": prompt]]
        ]
        
        AF.request(apiURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .responseDecodable(of: ChatCompletion.self) { response in
                switch response.result {
                case .success(let chatCompletion):
                    if let assistantMessage = chatCompletion.choices.first?.message.content {
                        completion(.success(assistantMessage)) // Removed the card variable here
                    } else {
                        completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No assistant message found in response."])))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
}





