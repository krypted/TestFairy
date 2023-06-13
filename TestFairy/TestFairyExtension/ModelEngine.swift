//
//  ModelEngine.swift
//  TestFairyExtension
//
//  Created by Charles Edge on 05/06/23.
//

import Foundation
import OpenAIKit

public class GPT3dot5TurboEngine {
    let openAIClient: Client
    var isCodeLine = false
    
    public init(openAIClient: Client) {
        self.openAIClient = openAIClient
    }
    
    public func getResponse(from queryString: String) async throws -> [String] {
        do {
            let completion = try await openAIClient.chats.create(model: Model.GPT3.gpt3_5Turbo,
                                                                 messages: [
                .system(content: "Reply using only Swift code, no text."),
                .user(content: "Create a unit test class for the following code:"),
                .user(content: queryString)
                             ])
            
            var resultText: [String] = []
            
            completion.choices.forEach { choice in
                let lineContent = choice.message.content.split(separator: "\n")
                
                for line in lineContent {
                    let lineString = String(line)
                    
                    if lineString.contains("```swift") {
                        isCodeLine.toggle()
                        continue
                    }
                    
                    resultText.append(isCodeLine ? lineString : "// \(lineString)")
                }
                
            }
            
            return resultText.map {"\($0)\n" }
        } catch {
            throw error
        }
    }
}
