//
//  LoginScreenView.swift
//  StudySwift
//
//  Created by Myat Thu Ko on 4/29/23.
//

import SwiftUI

struct LoginScreenView: View {

    @EnvironmentObject var authModel: AuthViewModel
    
    @ObservedObject var viewModel: LoginScreenViewModel
    @State private var isUserValid: Bool = false
    @State private var showErrorMessage: Bool = false
    @State private var errorMessage: String = ""

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

                    if showErrorMessage {
                        Text(errorMessage)
                            .padding(.horizontal)
                            .foregroundColor(.red)
                    }
                }
                .padding(.horizontal, 16)

                Spacer()

                Button {
                    authModel.signIn(email: viewModel.email, password: viewModel.password)
                    
                //    if viewModel.isUserValid(){
                //        isUserValid = true
                //        showErrorMessage = false
                //        viewModel.login()
                //    } else {
                //        isUserValid = false
                //        showErrorMessage = true
                //        errorMessage = "Invalid email or password. Please try again."
                //    }
                } label: {
                    RoundedButtonView(title: "Login")
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
        .fullScreenCover(isPresented: $isUserValid, content: {
            LandingScreenView()
        })
        .navigationBarBackButtonHidden(true)
    }
}

struct LoginScreenView_Previews: PreviewProvider {
    static var previews: some View {
        LoginScreenView(viewModel: LoginScreenViewModel(email: "", password: ""))
    }
}
