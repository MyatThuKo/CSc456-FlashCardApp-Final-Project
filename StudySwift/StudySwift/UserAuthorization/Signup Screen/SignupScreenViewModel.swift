//
//  SignupScreenViewModel.swift
//  StudySwift
//
//  Created by Myat Thu Ko on 4/25/23.
//

import Foundation
import SwiftUI

class SignUpViewModel: ObservableObject {
    var email: String
    var password: String
    var confirmPassword: String
    
    init(email: String, password: String, confirmPassword: String) {
        self.email = email
        self.password = password
        self.confirmPassword = confirmPassword
    }

    func signUp() {
        let email = email
        let password = password
        let confirmPassword = confirmPassword
        
        print("Account created with \(email).")
    }
}
