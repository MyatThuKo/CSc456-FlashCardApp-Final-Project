//
//  StudySwiftApp.swift
//  StudySwift
//
//  Created by Myat Thu Ko on 4/12/23.
//

import SwiftUI

@main
struct StudySwiftApp: App {
    var body: some Scene {
        WindowGroup {
//            SignupScreenView(viewModel: SignUpViewModel(email: "", password: "", confirmPassword: ""))
            HomeScreenView()
                .preferredColorScheme(.dark)
        }
    }
}
