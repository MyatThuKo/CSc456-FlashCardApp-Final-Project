//
//  AuthViewModel.swift
//  StudySwift
//
//  Created by Anthony Liang on 5/7/23.
//
//  Ref: https://blog.codemagic.io/google-sign-in-firebase-authentication-using-swift/

import Foundation
import Firebase

class AuthViewModel: ObservableObject {
    enum SignInState {
        case signedIn
        case signedOut
    }
    
    @Published var state: SignInState = .signedOut
    private var isDoingTask = false
    
    func signUp(email: String, password: String) {
        if self.isDoingTask {
            return
        }
        
        self.isDoingTask = true
        Auth.auth().createUser(withEmail: email, password: password) { user, error in
            if error != nil {
                print(error?.localizedDescription ?? "Failed to create account.")
            } else {
                print("Current User Id: \(user?.user.uid ?? "")")
                self.state = .signedIn
            }
            self.isDoingTask = false
        }
    }
    
    func signIn(email: String, password: String) {
        if self.isDoingTask {
            return
        }
        
        self.isDoingTask = true
        Auth.auth().signIn(withEmail: email, password: password) { user, error in
            if error != nil {
                print(error?.localizedDescription ?? "Failed to create account.")
            } else {
                print("Current User Id: \(user?.user.uid ?? "")")
                self.state = .signedIn
            }
            self.isDoingTask = false
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            state = .signedOut
        } catch {
            print(error.localizedDescription)
        }
    }
}
