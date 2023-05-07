//
//  StudySwiftApp.swift
//  StudySwift
//
//  Created by Myat Thu Ko on 4/12/23.
//

import SwiftUI
import Firebase

@main
struct StudySwiftApp: App {
    @StateObject var authModel = AuthViewModel()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        // WindowGroup {
        //     SignupScreenView(viewModel: SignUpViewModel(email: "", password: "", confirmPassword: ""))
        //         .preferredColorScheme(.dark)
        // }
        WindowGroup {
            ContentView()
                .environmentObject(authModel)
        }
    }
}
