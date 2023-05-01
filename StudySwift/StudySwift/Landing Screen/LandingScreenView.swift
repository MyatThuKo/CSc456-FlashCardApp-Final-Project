//
//  LandingScreenView.swift
//  StudySwift
//
//  Created by Myat Thu Ko on 5/1/23.
//

import SwiftUI

struct LandingScreenView: View {
    var body: some View {
        NavigationView {
            TabView {
                HomeScreenView()
                    .tabItem {
                        Label("Home", systemImage: "house")
                            .foregroundColor(Color("buttonColor"))
                    }
                ProfileScreenView(viewModel: ProfileScreenViewModel(email: "", oldPassword: "", newPassword: "", confirmPassword: ""))
                    .tabItem {
                        Label("Profile", systemImage: "person")
                            .foregroundColor(Color("flashcardColor"))
                    }
            }
            .tint(Color("flashcardColor"))
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct LandingScreenView_Previews: PreviewProvider {
    static var previews: some View {
        LandingScreenView()
    }
}
