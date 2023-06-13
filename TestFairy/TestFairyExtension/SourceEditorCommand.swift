//
//  SourceEditorCommand.swift
//  TestFairyExtension
//
//  Created by Charles Edge on 05/06/23.
//

import AsyncHTTPClient
import Foundation
import XcodeKit
import OpenAIKit

enum SAErrors: Error {
    case tokenMissing
}

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    
    static let httpClient = HTTPClient(eventLoopGroupProvider: .createNew)
    
    let tokenManager = TokenManager()
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        let prompt = getInput(for: invocation)
        
        guard let token = tokenManager.getToken() else {
            placeOutput(for: invocation, and: ["There is no token configured. Set it up using the app and try again."])
            completionHandler(SAErrors.tokenMissing)
            return
        }
        
        let configuration = Configuration(apiKey: token, organization: "")
        
        let openAIClient = OpenAIKit.Client(httpClient: SourceEditorCommand.httpClient, configuration: configuration)
        
        Task {
            do {
                let modelEngine = getModelEngine(withClient: openAIClient)
                
                let resultText = try await modelEngine.getResponse(from: prompt)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
                    placeOutput(for: invocation, and: resultText)
                    completionHandler(nil)
                }
            } catch let error {
                placeOutput(for: invocation, and: [String(describing: error)])
                completionHandler(error)
            }
        }
    }
    
    func getInput(for invocation: XCSourceEditorCommandInvocation) -> String {
        if let firstSelection = invocation.buffer.selections.firstObject as? XCSourceTextRange,
           let lastSelection = invocation.buffer.selections.lastObject as? XCSourceTextRange {
            guard firstSelection.start.line < lastSelection.end.line else {
                return "\(invocation.buffer.lines[firstSelection.start.line])"
            }
            
            var selectedLines = ""
            
            for index in firstSelection.start.line...lastSelection.end.line {
                selectedLines += "\(invocation.buffer.lines[index])\n"
            }
            
            return selectedLines
        } else {
            return invocation.buffer.lines.map { line in
                return "\(line)"
            }.joined(separator: "\n")
        }
    }
    
    func placeOutput(for invocation: XCSourceEditorCommandInvocation, and output: [String]) {
        if let firstSelection = invocation.buffer.selections.firstObject as? XCSourceTextRange,
           let lastSelection = invocation.buffer.selections.lastObject as? XCSourceTextRange {
            if firstSelection.start.line < lastSelection.end.line {
                invocation.buffer.lines.removeObject(at: firstSelection.start.line)
            } else {
                for index in firstSelection.start.line...lastSelection.end.line {
                    invocation.buffer.lines.removeObject(at: index)
                }
            }
            
            output.reversed().forEach { outputLine in
                invocation.buffer.lines.insert(outputLine, at: firstSelection.start.line)
            }
        } else {
            invocation.buffer.lines.removeAllObjects()
            invocation.buffer.lines.addObjects(from: output)
        }
    }
    
    func getModelEngine(withClient client: OpenAIKit.Client) -> GPT3dot5TurboEngine {
        return GPT3dot5TurboEngine(openAIClient: client)
    }
}
