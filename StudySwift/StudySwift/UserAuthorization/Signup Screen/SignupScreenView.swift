//
//  SignupScreenView.swift
//  StudySwift
//
//  Created by Myat Thu Ko on 4/25/23.
//

import SwiftUI

struct SignupScreenView: View {
    @ObservedObject var viewModel: SignUpViewModel
    @State private var isPasswordSame: Bool = true
    @State private var isFormEmpty: Bool = false
    
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
                    
                    if(!isPasswordSame && !viewModel.password.isEmpty) {
                        Text("Passwords need to be the same.")
                            .padding(.horizontal)
                            .foregroundColor(.red)
                    }
                    
                    SecureField("Confirm Password", text: $viewModel.confirmPassword)
                        .textFieldStyle(RoundedTextFieldStyle())
                    
                    if(!isPasswordSame && !viewModel.password.isEmpty) {
                        Text("Passwords need to be the same.")
                            .padding(.horizontal)
                            .foregroundColor(.red)
                    }
                    
                    if isFormEmpty {
                        Text("Invalid input! Please try again!")
                            .foregroundColor(.red)
                            .padding(.horizontal)
                    }
                }
                .padding(.horizontal, 16)
                
                Spacer()
                
                Button {
                    isFormEmpty = viewModel.email.isEmpty || viewModel.password.isEmpty || viewModel.confirmPassword.isEmpty
                    if (viewModel.password == viewModel.confirmPassword && !isFormEmpty) {
                        isPasswordSame = true
                        viewModel.signUp()
                    } else {
                        isPasswordSame = false
                    }
                } label: {
                    Text("Sign up")
                        .foregroundColor(.black)
                        .frame(width: 150, height: 35)
                        .padding(.vertical)
                        .padding(.horizontal, 24)
                        .background(
                            Color("buttonColor")
                        )
                        .clipShape(Capsule(style: .continuous))
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
