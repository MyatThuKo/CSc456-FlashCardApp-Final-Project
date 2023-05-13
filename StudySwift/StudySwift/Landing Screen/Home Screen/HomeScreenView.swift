//
//  HomeScreenView.swift
//  StudySwift
//
//  Created by Myat Thu Ko on 5/1/23.
//

import SwiftUI

struct HomeScreenView: View {
    var body: some View {
        NavigationView {
            VStack {
                Image("mainLogo")
                    .resizable()
                    .scaledToFit()
                    .padding()
                
                Button {
                    // add flashcard
                } label: {
                    RoundedButtonView(title: "Add flashcard")
                }
                
                Spacer()
            }
            .background(Color("inAppBGColor"))
            .navigationBarBackButtonHidden(true)
        }
    }
}

struct HomeScreenView_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreenView()
    }
}
