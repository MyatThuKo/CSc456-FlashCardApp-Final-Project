//
//  ResetPasswordScreenViewModel.swift
//  StudySwift
//
//  Created by Myat Thu Ko on 4/29/23.
//

import Foundation

class ResetPasswordScreenViewModel: ObservableObject {
    var email: String
    
    init(email: String) {
        self.email = email
    }
    
    func resetPassword() {
        print("Reset password email sent to \(email).")
    }
    
    func sendResetPasswordEmail() -> Bool {
        return email == "reset@example.com"
    }
}
