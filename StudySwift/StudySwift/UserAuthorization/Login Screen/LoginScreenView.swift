//
//  LoginScreenView.swift
//  StudySwift
//
//  Created by Myat Thu Ko on 4/29/23.
//

import SwiftUI

struct LoginScreenView: View {
    
    @ObservedObject var viewModel: LoginScreenViewModel
    @State private var isFormEmpty: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                Image("loginLogo")
                    .resizable()
                    .scaledToFit()
                    .padding()
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 25) {
                    TextField("Email", text: $viewModel.email)
                        .textFieldStyle(RoundedTextFieldStyle())
                        .textInputAutocapitalization(.never)
                    
                    SecureField("Password", text: $viewModel.password)
                        .textFieldStyle(RoundedTextFieldStyle())
                    
                    if isFormEmpty {
                        Text("Invalid input! Please try again!")
                            .padding(.horizontal)
                            .foregroundColor(.red)
                    }
                }
                .padding(.horizontal, 16)
                
                Spacer()
                
                Button {
                    isFormEmpty = viewModel.email.isEmpty || viewModel.password.isEmpty
                    if !isFormEmpty {
                        viewModel.login()
                    }
                } label: {
                    Text("Login")
                        .foregroundColor(.black)
                        .frame(width: 150, height: 35)
                        .padding(.vertical)
                        .padding(.horizontal, 24)
                        .background(
                            Color("buttonColor")
                        )
                        .clipShape(Capsule(style: .continuous))
                }
                
                VStack(spacing: 15) {
                    Button {
                        print("Navigate to the sign up screen")
                    } label: {
                        NavigationLink(destination: SignupScreenView(viewModel: SignUpViewModel(email: "", password: "", confirmPassword: ""))) {
                            Text("New user? \(Text("Register here.").foregroundColor(Color("buttonColor")))")
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                        }
                    }
                    
                    Button {
                        print("Navigate to the reset password screen")
                    } label: {
                        NavigationLink(destination: (ResetPasswordScreenView(viewModel: ResetPasswordScreenViewModel(email: "")))) {
                            Text("Forgot password? \(Text("Reset here.").foregroundColor(Color("buttonColor")))")
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                        }
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

struct LoginScreenView_Previews: PreviewProvider {
    static var previews: some View {
        LoginScreenView(viewModel: LoginScreenViewModel(email: "", password: ""))
    }
}
