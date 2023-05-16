//
//  FlashcardCardView.swift
//  StudySwift
//
//  Created by Myat Thu Ko on 5/12/23.
//

import SwiftUI

struct FlashcardCardView: View {
    var title: String
    var text: String?
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            Text(title)
                .font(.title)
                .fontWeight(.bold)
            
            if let subtitle = text {
                Text(subtitle)
                    .font(.subheadline)
            }
        }
        .frame(minWidth: 150, minHeight: 150)
        .background(Color("flashcardColor"))
        .foregroundColor(.white)
        .cornerRadius(10)
    }
}

struct FlashcardCardView_Previews: PreviewProvider {
    static var previews: some View {
        FlashcardCardView(title: "Title", text: "Hello world")
    }
}
