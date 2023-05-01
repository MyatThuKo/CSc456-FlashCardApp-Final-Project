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
                    Text("Add Flashcard")
                        .foregroundColor(.black)
                        .frame(width: 150, height: 35)
                        .padding(.vertical)
                        .padding(.horizontal, 24)
                        .background(
                            Color("buttonColor")
                        )
                        .clipShape(Capsule(style: .continuous))
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
