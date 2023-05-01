//
//  ProfileScreenView.swift
//  StudySwift
//
//  Created by Myat Thu Ko on 5/1/23.
//

import SwiftUI

struct ProfileScreenView: View {

    @ObservedObject var viewModel: ProfileScreenViewModel
    @State private var errorMessage: String = ""
    @State private var isLogout: Bool = false
    @State private var isPasswordValid: Bool = true

    var body: some View {
        NavigationView {
            VStack {
                Image("mainLogo")
                    .resizable()
                    .scaledToFit()
                    .padding()

                Spacer()

                VStack(alignment: .leading, spacing: 25) {
                    TextField("Email", text: $viewModel.email)
                        .textFieldStyle(RoundedTextFieldStyle())
                        .textInputAutocapitalization(.never)

                    SecureField("Old Password", text: $viewModel.oldPassword)
                        .textFieldStyle(RoundedTextFieldStyle())

                    SecureField("New Password", text: $viewModel.newPassword)
                        .textFieldStyle(RoundedTextFieldStyle())

                    SecureField("Confirm Password", text: $viewModel.confirmPassword)
                        .textFieldStyle(RoundedTextFieldStyle())

                    if !isPasswordValid {
                        Text(errorMessage)
                            .padding(.horizontal)
                            .foregroundColor(.red)
                    }
                }
                .padding(.horizontal, 16)

                Spacer()

                Button {
                    if !viewModel.isValidPassword() {
                        isPasswordValid = false
                        errorMessage = "Password must be at least 6 characters long and contain at least one uppercase letter, one lowercase letter, and one special character."
                    } else if !viewModel.isSamePassword() {
                        isPasswordValid = false
                        errorMessage = "Passwords do not match! Please try again."
                    } else {
                        isPasswordValid = true
                        viewModel.resetPassword()
                    }
                } label: {
                    Text("Reset Password")
                        .foregroundColor(.black)
                        .frame(width: 150, height: 35)
                        .padding(.vertical)
                        .padding(.horizontal, 24)
                        .background(
                            Color("buttonColor")
                        )
                        .clipShape(Capsule(style: .continuous))
                }
                .padding()

                Button {
                    isLogout = true
                } label: {
                    Text("Logout")
                }
                .font(.system(size: 18))
                .foregroundColor(Color("buttonColor"))
                .frame(width: 150, height: 35)
                .padding(.vertical)
                .padding(.horizontal, 24)
                .background(
                    Capsule(style: .continuous)
                        .stroke(Color("buttonColor"), lineWidth: 3)
                )

            }
            .padding(.vertical)
            .background(Color("inAppBGColor"))

        }
        .navigationBarBackButtonHidden(true)
        .fullScreenCover(isPresented: $isLogout) {
            LoginScreenView(viewModel: LoginScreenViewModel(email: "", password: ""))
        }
    }
}

struct ProfileScreenView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileScreenView(viewModel: ProfileScreenViewModel(email: "", oldPassword: "", newPassword: "", confirmPassword: ""))
    }
}
