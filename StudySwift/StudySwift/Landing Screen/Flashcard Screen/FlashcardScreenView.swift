//
//  FlashcardScreenView.swift
//  StudySwift
//
//  Created by Myat Thu Ko on 5/12/23.
//

import SwiftUI

struct FlashcardScreenView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel: FlashcardScreenViewModel
    
    var body: some View {
        VStack {
            Spacer()
            
            Button {
                viewModel.flipFlashcard()
            } label: {
                FlashcardCardView(title: viewModel.currentFlashcard.category, text: viewModel.isShowingAnswer ? viewModel.currentFlashcard.answer : viewModel.currentFlashcard.question)
            }
            
            Spacer()
            
            HStack {
                Button(action: viewModel.goToPreviousFlashcard) {
                    Image(systemName: "arrow.backward")
                        .font(.title)
                }
                .padding()
                .disabled(!viewModel.canGoToPreviousFlashcard)
                
                Spacer()
                
                Button(action: viewModel.goToNextFlashcard) {
                    Image(systemName: "arrow.forward")
                        .font(.title)
                }
                .padding()
                .disabled(!viewModel.canGoToNextFlashcard)
            }
        }
        .padding()
        .background(Color("inAppBGColor"))
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
        .accentColor(Color("buttonColor"))
    }
    
    private var backButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "chevron.backward")
                .foregroundColor(Color("buttonColor")) 
        }
    }
}
