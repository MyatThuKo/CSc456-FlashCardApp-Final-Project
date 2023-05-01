//
//  RoundedButtonView.swift
//  StudySwift
//
//  Created by Myat Thu Ko on 5/1/23.
//

import SwiftUI

struct RoundedButtonView: View {
    var title: String
    
    var body: some View {
        Text(title)
            .foregroundColor(.black)
            .frame(width: 150, height: 35)
            .padding(.vertical)
            .padding(.horizontal, 24)
            .background(
                Color("buttonColor")
            )
            .clipShape(Capsule(style: .continuous))
    }
}

struct RoundedButtonView_Previews: PreviewProvider {
    static var previews: some View {
        RoundedButtonView(title: "Button")
    }
}
