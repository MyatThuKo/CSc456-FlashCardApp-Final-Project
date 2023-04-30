//
//  LoginScreenViewModel.swift
//  StudySwift
//
//  Created by Myat Thu Ko on 4/29/23.
//

import Foundation

class LoginScreenViewModel: ObservableObject {
    var email: String
    var password: String
    
    init(email: String, password: String) {
        self.email = email
        self.password = password
    }
    
    func login() {
        let email = email
        let password = password
        
        print("Login with email: \(email).")
    }
}
