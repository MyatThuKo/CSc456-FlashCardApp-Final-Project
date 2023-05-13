//
//  SignupScreenView.swift
//  StudySwift
//
//  Created by Myat Thu Ko on 4/25/23.
//

import SwiftUI

struct SignupScreenView: View {
    @ObservedObject var viewModel: SignUpViewModel
    @State private var isPasswordValid: Bool = true
    @State private var isEmailValid: Bool = true
    @State private var errorMessage: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                Image("loginLogo")
                    .resizable()
                    .scaledToFit()
                    .padding(.top, 25)
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 25) {
                    TextField("Email", text: $viewModel.email)
                        .textFieldStyle(RoundedTextFieldStyle())
                        .textInputAutocapitalization(.never)
                    
                    SecureField("Password", text: $viewModel.password)
                        .textFieldStyle(RoundedTextFieldStyle())
                    
                    SecureField("Confirm Password", text: $viewModel.confirmPassword)
                        .textFieldStyle(RoundedTextFieldStyle())
                    
                    if !isEmailValid {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                    } else if !isPasswordValid {
                        Text(errorMessage)
                            .fixedSize(horizontal: false, vertical: true)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                    }
                }
                .padding(.horizontal, 16)
                
                Spacer()
                
                Button {
                    if !viewModel.isValidEmail() {
                        isEmailValid = false
                        isPasswordValid = true
                        errorMessage = "Invalid email!"
                    } else if !viewModel.isValidPassword() {
                        isPasswordValid = false
                        isEmailValid = true
                        errorMessage = "Password must be at least 6 characters long and contain at least one uppercase letter, one lowercase letter, and one special character."
                    } else if !viewModel.isSamePassword() {
                        isPasswordValid = false
                        isEmailValid = true
                        errorMessage = "Passwords do not match! Please try again."
                    } else {
                        isEmailValid = true
                        isPasswordValid = true
                        viewModel.signUp()
                    }
                } label: {
                    RoundedButtonView(title: "Sign up")
                }
                
                Button {
                    print("Navigate to the login screen")
                } label: {
                    NavigationLink(destination: LoginScreenView(viewModel: LoginScreenViewModel(email: "", password: ""))) {
                        Text("Already a user? \(Text("Login here.").foregroundColor(Color("buttonColor")))")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                    }
                }
                .padding(.top, 50)
            }
            .padding(.vertical)
            .background(Color("mainBGColor"))
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct RoundedTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.vertical)
            .padding(.horizontal, 24)
            .background(
                Color(UIColor.systemGray6)
            )
            .clipShape(Capsule(style: .continuous))
    }
}

struct SignupScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SignupScreenView(viewModel: SignUpViewModel(email: "", password: "", confirmPassword: ""))
    }
}
