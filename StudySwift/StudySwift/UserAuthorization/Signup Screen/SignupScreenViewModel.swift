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
        print("Sign up successful!\nEmail: \(email)")
    }
    
    func isValidEmail() -> Bool {
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}")
        return emailPredicate.evaluate(with: email)
    }
    
    func isValidPassword() -> Bool {
        let passwordRegex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*[@#$%^&+=])(?=.*[0-9]).{6,}$"
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordTest.evaluate(with: password)
    }
    
    func isSamePassword() -> Bool {
        return password == confirmPassword
    }
}
