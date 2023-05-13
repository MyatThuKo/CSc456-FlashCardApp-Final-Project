//
//  ContentView.swift
//  StudySwift
//
//  Created by Myat Thu Ko on 4/12/23.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authModel: AuthViewModel
    @EnvironmentObject var dataStoreModel: DataStoreModel
    
    var body: some View {
        switch authModel.state {
            case .signedIn: LandingScreenView()
            case .signedOut: LoginScreenView(viewModel: LoginScreenViewModel(email: "", password: ""))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AuthViewModel.sharedInstance)
            .environmentObject(DataStoreModel.sharedInstance)
    }
}
