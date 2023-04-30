//
//  ResetPasswordScreenView.swift
//  StudySwift
//
//  Created by Myat Thu Ko on 4/29/23.
//

import SwiftUI

struct ResetPasswordScreenView: View {
    
    @ObservedObject var viewModel: ResetPasswordScreenViewModel
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
                        .autocapitalization(.none)
                    
                    if isFormEmpty {
                        Text("Invalid input! Please try again!")
                            .padding(.horizontal)
                            .foregroundColor(.red)
                    }
                }
                .padding(.horizontal, 16)
                
                Spacer()
                
                Button {
                    isFormEmpty = viewModel.email.isEmpty
                    if !isFormEmpty {
                        viewModel.resetPassword()
                    }
                } label: {
                    Text("Reset password")
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
                        print("Navigate to the login screen")
                    } label: {
                        NavigationLink(destination: LoginScreenView(viewModel: LoginScreenViewModel(email: "", password: ""))){
                            Text("Existing user? \(Text("Login here.").foregroundColor(Color("buttonColor")))")
                                .foregroundColor(.white)
                        }
                    }
                    
                    Button {
                        print("Navigate to the sign up screen")
                    } label: {
                        NavigationLink(destination: SignupScreenView(viewModel: SignUpViewModel(email: "", password: "", confirmPassword: ""))) {
                            Text("New user? \(Text("Register here.").foregroundColor(Color("buttonColor")))")
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

struct ResetPasswordScreenView_Previews: PreviewProvider {
    static var previews: some View {
        ResetPasswordScreenView(viewModel: ResetPasswordScreenViewModel(email: ""))
    }
}
