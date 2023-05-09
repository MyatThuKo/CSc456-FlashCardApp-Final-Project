//
//  ProfileScreenViewModel.swift
//  StudySwift
//
//  Created by Myat Thu Ko on 5/1/23.
//

import Foundation

class ProfileScreenViewModel: ObservableObject {
    var email: String
    var oldPassword: String
    var newPassword: String
    var confirmPassword: String

    init(email: String, oldPassword: String, newPassword: String, confirmPassword: String) {
        self.email = email
        self.oldPassword = oldPassword
        self.newPassword = newPassword
        self.confirmPassword = confirmPassword
    }

    func resetPassword() {
        //
    }

    func isValidPassword() -> Bool {
        let passwordRegex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*[@#$%^&+=])(?=.*[0-9]).{6,}$"
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordTest.evaluate(with: oldPassword)
    }

    func isSamePassword() -> Bool {
        return (newPassword == confirmPassword && oldPassword != newPassword)
    }
}
