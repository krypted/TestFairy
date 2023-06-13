//
//  TokenManager.swift
//  TestFairy
//
//  Created by Charles Edge on 05/06/23.
//

import Foundation

public class TokenManager {
    let keychainHelper = KeychainHelper.standard
    
    enum Constants {
        static let account = "com.krypted.test-fairy"
        static let service = "token"
    }
    
    public func getToken() -> String? {
        return keychainHelper.read(service: Constants.service, account: Constants.account, type: String.self)
    }
    
    public func set(token: String) {
        keychainHelper.save(token, service: Constants.service, account: Constants.account)
    }
    
    public init() {}
}
